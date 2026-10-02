import DawnCore
import Foundation
import Testing
@testable import DawnWrist

/// Arming and following edits to the alarm.
@MainActor
struct WakeCoordinatorArmingTests {
    let rig = CoordinatorRig()

    @Test func activatingWithARingDueArmsItsWindowAndDropsTheNudge() async {
        rig.setAlarm()
        let wake = rig.coordinator()
        await wake.activate()
        #expect(rig.session.scheduled == [rig.nextSeven.addingTimeInterval(-1800)])
        #expect(wake.arming.armed?.windowEnd == rig.nextSeven)
        #expect(await rig.heart.asked == 1)
        // No reminder for the ring just armed; the nights after it keep theirs.
        let lead = Tuning.Wake.nudgeLead
        #expect(await rig.nudges.reminders?.contains(rig.nextSeven.addingTimeInterval(-lead)) == false)
        #expect(await rig.nudges.reminders?.contains(rig.calendar.date(byAdding: .day, value: 1, to: rig.nextSeven)!.addingTimeInterval(-lead)) == true)
        #expect(await rig.nudges.widget == .some(nil))
    }

    @Test func withNothingDueNothingIsArmed() async {
        let wake = rig.coordinator()
        await wake.activate()
        #expect(rig.session.scheduled.isEmpty)
        #expect(wake.plan == nil)
    }

    @Test func switchingTheAlarmOffStandsTheArmedWindowDownAndMovingItRearms() async {
        let id = UUID()
        rig.setAlarm(id: id)
        let wake = rig.coordinator()
        await wake.activate()
        rig.setAlarm(hour: 7, minute: 30, id: id)
        await wake.follow()
        #expect(rig.session.cancels == 1)
        #expect(wake.arming.armed?.windowEnd == rig.nextSeven.addingTimeInterval(1800))
        rig.setAlarm(on: false, id: id)
        await wake.follow()
        #expect(wake.arming.armed == nil)
    }

    @Test func inTheBackgroundAStaleWindowIsStoodDownAndTheNudgeOffered() async {
        let id = UUID()
        rig.setAlarm(id: id)
        let wake = rig.coordinator()
        await wake.activate()
        rig.active = false
        rig.setAlarm(hour: 7, minute: 30, id: id)
        await wake.follow()
        #expect(wake.arming.armed == nil)
        #expect(rig.session.scheduled.count == 1)
        #expect(await rig.nudges.reminder == .some(rig.nextSeven.addingTimeInterval(1800 - Tuning.Wake.nudgeLead)))
    }

    @Test func anUnansweredHeartRatePromptDoesNotHoldUpArming() async {
        rig.heart = FakeHeartRateStream(answered: false, hangs: true)
        rig.setAlarm()
        let wake = rig.coordinator()
        let activating = Task { await wake.activate() }
        defer { activating.cancel() }
        try? await Task.sleep(for: .milliseconds(100))
        #expect(wake.arming.armed?.windowEnd == rig.nextSeven)
    }
}
