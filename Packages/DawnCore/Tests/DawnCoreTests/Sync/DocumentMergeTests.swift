import Foundation
import Testing
@testable import DawnCore

/// Two copies of one alarm document, edited apart and merged both ways.
struct DocumentMergeTests {
    private let f = MergeFixture()
    private var id: UUID { f.id }
    private func at(_ minutes: Double) -> Date { f.at(minutes) }
    private func shared() -> (phone: AlarmDocument, watch: AlarmDocument) { f.shared() }
    private func both(_ phone: AlarmDocument, _ watch: AlarmDocument) -> AlarmDocument { f.both(phone, watch) }
    private func edit(_ doc: inout AlarmDocument, at time: Date, by who: Replica, _ change: (inout AlarmSettings) -> Void) {
        f.edit(&doc, at: time, by: who, change)
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

    @Test func aTieGoesToThePhoneWhicheverCopyIsNewer() {
        var (phone, watch) = shared()
        edit(&phone, at: at(1), by: .phone) { $0.windowMinutes = 20 }
        edit(&watch, at: at(1), by: .watch) { $0.windowMinutes = 15 }
        watch.bump(at: at(1), by: .watch)
        #expect(watch.revision > phone.revision)
        #expect(both(phone, watch).alarm(id)!.settings.windowMinutes == 20)
    }

    @Test func anAlarmCreatedOnEitherDeviceReachesTheOther() {
        var (phone, watch) = shared()
        let fromPhone = UUID(), fromWatch = UUID()
        phone.save(AlarmSettings(time: f.seven), id: fromPhone, at: at(1), by: .phone)
        watch.save(AlarmSettings(time: f.seven), id: fromWatch, at: at(1), by: .watch)
        let merged = both(phone, watch)
        #expect(Set(merged.alarms.map(\.id)) == [id, fromPhone, fromWatch])
    }

    @Test func mergingACopyWithItselfChangesNothing() {
        let (phone, _) = shared()
        #expect(DocumentMerge.merge(phone, phone).sameContent(as: phone))
    }
}
