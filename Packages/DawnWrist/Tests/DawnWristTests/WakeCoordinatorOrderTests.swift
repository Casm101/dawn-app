import DawnCore
import Foundation
import Testing
@testable import DawnWrist

/// Steps that overlap: a window ending, a window replaced, and what the next night gets.
@MainActor
struct WakeCoordinatorOrderTests {
    let rig = CoordinatorRig()

    @Test func aWindowThatEndsInTheBackgroundSetsTheNextNightsReminder() async {
        rig.now = Date()
        let ring = rig.calendar.date(bySettingHour: rig.calendar.component(.hour, from: rig.now), minute: rig.calendar.component(.minute, from: rig.now), second: 0, of: rig.now)!.addingTimeInterval(120)
        rig.setAlarm(hour: rig.calendar.component(.hour, from: ring), minute: rig.calendar.component(.minute, from: ring), window: 10)
        let wake = rig.coordinator()
        await wake.activate()
        let running = Task { await wake.run() }
        defer { running.cancel() }
        rig.active = false
        rig.now = ring.addingTimeInterval(-Tuning.Wake.safetyMargin - 1)
        rig.session.emit(.started(expires: nil))
        try? await Task.sleep(for: .milliseconds(100))
        rig.now = ring.addingTimeInterval(-Tuning.Wake.safetyMargin)
        try? await Task.sleep(for: .milliseconds(200))
        rig.session.emit(.ended(failed: false))
        try? await Task.sleep(for: .milliseconds(100))
        #expect(rig.session.wakes == 1)
        #expect(await rig.nudges.reminder == .some(rig.calendar.date(byAdding: .day, value: 1, to: ring)!.addingTimeInterval(-Tuning.Wake.nudgeLead)))
    }

    @Test func theEndOfAReplacedSessionLeavesTheNewWindowArmedAndIsRecordedOnce() async {
        let id = UUID()
        rig.now = Date()
        let ring = rig.now.addingTimeInterval(600)
        let clock = DateComponents(hour: rig.calendar.component(.hour, from: ring), minute: rig.calendar.component(.minute, from: ring))
        rig.setAlarm(hour: clock.hour!, minute: clock.minute!, window: 30, id: id)
        let wake = rig.coordinator()
        await wake.activate()
        let running = Task { await wake.run() }
        defer { running.cancel() }
        rig.session.emit(.started(expires: nil))
        try? await Task.sleep(for: .milliseconds(100))
        // Moving the alarm cancels the running session, whose end arrives after the new one is armed.
        rig.setAlarm(hour: clock.hour!, minute: (clock.minute! + 5) % 60, window: 30, id: id)
        await wake.follow()
        try? await Task.sleep(for: .milliseconds(100))
        #expect(wake.arming.armed != nil)
        #expect(rig.sent.map(\.result) == [.sessionEnded])
    }

    @Test func activatingAsksForTheReminderPermission() async {
        rig.setAlarm()
        await rig.coordinator().activate()
        #expect(await rig.nudges.authorizations == 1)
    }

    @Test func remindersAreBookedForEveryUnarmedNightOfTheWeekAhead() async {
        rig.setAlarm()
        rig.active = false
        await rig.coordinator().follow()
        #expect(await rig.nudges.reminders?.count == 7)
        #expect(await rig.nudges.reminder == .some(rig.nextSeven.addingTimeInterval(-Tuning.Wake.nudgeLead)))
    }

    @Test func aCardHandOverThatNeverReturnsHoldsUpNeitherPermissionNorTheNextStep() async {
        rig.nudges = FakeNudges(widgetHangs: true)
        let id = UUID()
        rig.setAlarm(id: id)
        let wake = rig.coordinator()
        let activating = Task { await wake.activate() }
        defer { activating.cancel() }
        try? await Task.sleep(for: .milliseconds(100))
        #expect(wake.arming.armed != nil)
        #expect(await rig.nudges.authorizations == 1)
        rig.setAlarm(on: false, id: id)
        let following = Task { await wake.follow() }
        defer { following.cancel() }
        try? await Task.sleep(for: .milliseconds(100))
        #expect(wake.arming.armed == nil)
    }
}
