import Foundation
import Testing
@testable import DawnCore

/// One device deletes the alarm while the other edits it, in every order and from either side.
struct DocumentMergeDeletionTests {
    private let f = MergeFixture()

    private static func other(_ replica: Replica) -> Replica { replica == .phone ? .watch : .phone }

    @Test(arguments: [Replica.phone, .watch])
    func aDeletionWinsOverAnEarlierEditOnTheOtherDevice(deleter: Replica) {
        let merged = f.editAndDelete(editBy: Self.other(deleter), at: f.at(1), deleteBy: deleter, at: f.at(2))
        #expect(merged.alarm(f.id) == nil)
        #expect(merged.tombstone(f.id) != nil)
    }

    @Test(arguments: [Replica.phone, .watch])
    func anEditAfterADeletionOnTheOtherDeviceBringsTheAlarmBack(editor: Replica) {
        let merged = f.editAndDelete(editBy: editor, at: f.at(2), deleteBy: Self.other(editor), at: f.at(1))
        #expect(merged.alarm(f.id)?.settings.time == ClockTime(hour: 8, minute: 0)!)
        #expect(merged.tombstone(f.id) == nil)
    }

    @Test func aPhoneEditAtTheSameInstantAsAWatchDeletionKeepsTheAlarm() {
        let merged = f.editAndDelete(editBy: .phone, at: f.at(1), deleteBy: .watch, at: f.at(1))
        #expect(merged.alarm(f.id)?.settings.time == ClockTime(hour: 8, minute: 0)!)
    }

    @Test func aPhoneDeletionAtTheSameInstantAsAWatchEditRemovesTheAlarm() {
        let merged = f.editAndDelete(editBy: .watch, at: f.at(1), deleteBy: .phone, at: f.at(1))
        #expect(merged.alarm(f.id) == nil)
    }

    @Test(arguments: [Replica.phone, .watch])
    func aDeletionBeatsAnEditTheSameDeviceMadeAtTheSameInstant(device: Replica) {
        var (phone, watch) = f.shared()
        if device == .phone {
            f.edit(&phone, at: f.at(1), by: .phone) { $0.isEnabled = false }
            watch = f.both(phone, watch)
            phone.remove(f.id, at: f.at(1), by: .phone)
        } else {
            f.edit(&watch, at: f.at(1), by: .watch) { $0.isEnabled = false }
            phone = f.both(phone, watch)
            watch.remove(f.id, at: f.at(1), by: .watch)
        }
        #expect(f.both(phone, watch).alarm(f.id) == nil)
    }

    @Test func deletedOnBothIsDeleted() {
        var (phone, watch) = f.shared()
        phone.remove(f.id, at: f.at(1), by: .phone)
        watch.remove(f.id, at: f.at(2), by: .watch)
        #expect(f.both(phone, watch).alarms.isEmpty)
    }
}
