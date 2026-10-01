import Foundation
import Testing
@testable import DawnCore

/// Saving an editor that was opened before a change arrived from the other device.
struct AlarmSettingsRebaseTests {
    private let original = AlarmSettings(time: ClockTime(hour: 7, minute: 0)!, repeatDays: Weekday.weekdays)

    @Test func aSettingTheUserDidNotTouchKeepsTheChangeThatArrived() {
        var draft = original
        draft.time = ClockTime(hour: 6, minute: 30)!
        var current = original
        current.repeatDays = Weekday.weekend
        current.sound = .pulse
        let saved = draft.rebased(from: original, onto: current)
        #expect(saved.time == ClockTime(hour: 6, minute: 30)!)
        #expect(saved.repeatDays == Weekday.weekend)
        #expect(saved.sound == .pulse)
    }

    @Test func aSettingTheUserChangedWinsOverTheChangeThatArrived() {
        var draft = original
        draft.windowMinutes = 15
        var current = original
        current.windowMinutes = 25
        #expect(draft.rebased(from: original, onto: current).windowMinutes == 15)
    }

    @Test func anUntouchedEditorChangesNothing() {
        var current = original
        current.isEnabled = false
        current.snoozeMinutes = 5
        #expect(original.rebased(from: original, onto: current) == current)
    }

    @Test func anEditOfAnAlarmDeletedMeanwhileStandsAsItIs() {
        var draft = original
        draft.time = ClockTime(hour: 6, minute: 0)!
        #expect(draft.rebased(from: original, onto: nil) == draft)
    }
}
