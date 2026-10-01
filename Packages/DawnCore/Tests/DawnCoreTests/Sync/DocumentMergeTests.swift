import Foundation
import Testing
@testable import DawnCore

/// Two copies of one alarm document, edited apart and merged both ways.
struct DocumentMergeTests {
    private let id = UUID()
    private let t0 = SleepFixture.at(0, "20:00")
    private func at(_ minutes: Double) -> Date { t0.addingTimeInterval(minutes * 60) }
    private let seven = ClockTime(hour: 7, minute: 0)!

    /// The alarm both devices start from, created on the phone and already on the Watch.
    private func shared() -> (phone: AlarmDocument, watch: AlarmDocument) {
        var phone = AlarmDocument()
        phone.save(AlarmSettings(time: seven), id: id, at: t0, by: .phone)
        var watch = phone
        watch.origin = .watch
        return (phone, watch)
    }

    private func both(_ phone: AlarmDocument, _ watch: AlarmDocument) -> AlarmDocument {
        let onPhone = DocumentMerge.merge(phone, watch)
        let onWatch = DocumentMerge.merge(watch, phone)
        #expect(onPhone.sameContent(as: onWatch))
        return onPhone
    }

    private func edit(_ doc: inout AlarmDocument, at time: Date, by who: Replica, _ change: (inout AlarmSettings) -> Void) {
        var settings = doc.alarm(id)!.settings
        change(&settings)
        doc.save(settings, id: id, at: time, by: who)
    }

    @Test func differentFieldsEditedApartBothSurvive() {
        var (phone, watch) = shared()
        edit(&phone, at: at(1), by: .phone) { $0.time = ClockTime(hour: 6, minute: 30)! }
        edit(&watch, at: at(2), by: .watch) { $0.repeatDays = Weekday.weekend }
        let merged = both(phone, watch).alarm(id)!.settings
        #expect(merged.time == ClockTime(hour: 6, minute: 30)!)
        #expect(merged.repeatDays == Weekday.weekend)
    }

    @Test func theNewerEditToOneFieldWinsWhicheverDeviceMadeIt() {
        var (phone, watch) = shared()
        edit(&phone, at: at(1), by: .phone) { $0.time = ClockTime(hour: 6, minute: 30)! }
        edit(&watch, at: at(2), by: .watch) { $0.time = ClockTime(hour: 6, minute: 45)! }
        #expect(both(phone, watch).alarm(id)!.settings.time == ClockTime(hour: 6, minute: 45)!)
        var (phone2, watch2) = shared()
        edit(&watch2, at: at(1), by: .watch) { $0.time = ClockTime(hour: 6, minute: 45)! }
        edit(&phone2, at: at(2), by: .phone) { $0.time = ClockTime(hour: 6, minute: 30)! }
        #expect(both(phone2, watch2).alarm(id)!.settings.time == ClockTime(hour: 6, minute: 30)!)
    }

    @Test func aTieOnTimeAndRevisionGoesToThePhone() {
        var (phone, watch) = shared()
        edit(&phone, at: at(1), by: .phone) { $0.windowMinutes = 20 }
        edit(&watch, at: at(1), by: .watch) { $0.windowMinutes = 15 }
        #expect(phone.revision == watch.revision)
        #expect(both(phone, watch).alarm(id)!.settings.windowMinutes == 20)
    }

    @Test func aTieOnTimeGoesToTheHigherRevision() {
        var (phone, watch) = shared()
        edit(&phone, at: at(1), by: .phone) { $0.windowMinutes = 20 }
        edit(&watch, at: at(1), by: .watch) { $0.windowMinutes = 15 }
        watch.bump(at: at(1), by: .watch)
        #expect(both(phone, watch).alarm(id)!.settings.windowMinutes == 15)
    }

    @Test func anAlarmCreatedOnEitherDeviceReachesTheOther() {
        var (phone, watch) = shared()
        let fromPhone = UUID(), fromWatch = UUID()
        phone.save(AlarmSettings(time: seven), id: fromPhone, at: at(1), by: .phone)
        watch.save(AlarmSettings(time: seven), id: fromWatch, at: at(1), by: .watch)
        let merged = both(phone, watch)
        #expect(Set(merged.alarms.map(\.id)) == [id, fromPhone, fromWatch])
    }

    @Test func aDeletionWinsOverEditsMadeBeforeIt() {
        var (phone, watch) = shared()
        edit(&watch, at: at(1), by: .watch) { $0.isEnabled = false }
        phone.remove(id, at: at(2), by: .phone)
        let merged = both(phone, watch)
        #expect(merged.alarm(id) == nil)
        #expect(merged.tombstone(id) != nil)
    }

    @Test func anEditMadeAfterADeletionBringsTheAlarmBack() {
        var (phone, watch) = shared()
        watch.remove(id, at: at(1), by: .watch)
        edit(&phone, at: at(2), by: .phone) { $0.time = ClockTime(hour: 8, minute: 0)! }
        let merged = both(phone, watch)
        #expect(merged.alarm(id)?.settings.time == ClockTime(hour: 8, minute: 0)!)
        #expect(merged.tombstone(id) == nil)
    }

    @Test func deletedOnBothIsDeleted() {
        var (phone, watch) = shared()
        phone.remove(id, at: at(1), by: .phone)
        watch.remove(id, at: at(2), by: .watch)
        #expect(both(phone, watch).alarms.isEmpty)
    }

    @Test func mergingACopyWithItselfChangesNothing() {
        let (phone, _) = shared()
        #expect(DocumentMerge.merge(phone, phone).sameContent(as: phone))
    }
}
