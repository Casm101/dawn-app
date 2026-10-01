import Foundation
import Testing
@testable import DawnCore

/// One alarm the phone created and the Watch already holds, for editing apart and merging both ways.
struct MergeFixture {
    let id = UUID()
    let t0 = SleepFixture.at(0, "20:00")
    let seven = ClockTime(hour: 7, minute: 0)!

    func at(_ minutes: Double) -> Date { t0.addingTimeInterval(minutes * 60) }

    /// The document on each device before either edits.
    func shared() -> (phone: AlarmDocument, watch: AlarmDocument) {
        var phone = AlarmDocument()
        phone.save(AlarmSettings(time: seven), id: id, at: t0, by: .phone)
        var watch = phone
        watch.origin = .watch
        return (phone, watch)
    }

    /// Merges on both devices, checks they agree, and returns the phone's result.
    func both(_ phone: AlarmDocument, _ watch: AlarmDocument) -> AlarmDocument {
        let onPhone = DocumentMerge.merge(phone, watch)
        let onWatch = DocumentMerge.merge(watch, phone)
        #expect(onPhone.sameContent(as: onWatch))
        return onPhone
    }

    func edit(_ doc: inout AlarmDocument, at time: Date, by who: Replica, _ change: (inout AlarmSettings) -> Void) {
        var settings = doc.alarm(id)!.settings
        change(&settings)
        doc.save(settings, id: id, at: time, by: who)
    }

    /// One device changes the alarm's time and the other, or the same one, deletes it; merged both ways.
    func editAndDelete(editBy editor: Replica, at editTime: Date, deleteBy deleter: Replica, at deleteTime: Date) -> AlarmDocument {
        let (phone, watch) = shared()
        var docs: [Replica: AlarmDocument] = [.phone: phone, .watch: watch]
        edit(&docs[editor]!, at: editTime, by: editor) { $0.time = ClockTime(hour: 8, minute: 0)! }
        docs[deleter]!.remove(id, at: deleteTime, by: deleter)
        return both(docs[.phone]!, docs[.watch]!)
    }
}
