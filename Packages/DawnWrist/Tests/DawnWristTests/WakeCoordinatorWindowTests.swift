import DawnCore
import Foundation
import Testing
@testable import DawnWrist

/// The running window: starting, waking, replacing, refusal.
@MainActor
struct WakeCoordinatorWindowTests {
    let rig = CoordinatorRig()

    @Test func aSessionThatStartsWithoutACurrentPlanIsEndedAtOnce() async {
        let wake = rig.coordinator()
        let running = Task { await wake.run() }
        defer { running.cancel() }
        rig.session.emit(.started(expires: nil))
        try? await Task.sleep(for: .milliseconds(100))
        #expect(rig.session.cancels == 1)
        #expect(rig.session.wakes == 0)
    }

    @Test func aStartedWindowWakesAtItsDeadlineWithoutHeartRateAndArmsTheNextNightOnOpening() async {
        rig.now = Date()
        let ring = rig.calendar.date(bySettingHour: rig.calendar.component(.hour, from: rig.now), minute: rig.calendar.component(.minute, from: rig.now), second: 0, of: rig.now)!.addingTimeInterval(120)
        rig.setAlarm(hour: rig.calendar.component(.hour, from: ring), minute: rig.calendar.component(.minute, from: ring), window: 10)
        let wake = rig.coordinator()
        await wake.activate()
        let running = Task { await wake.run() }
        defer { running.cancel() }
        rig.now = ring.addingTimeInterval(-Tuning.Wake.safetyMargin - 1)
        rig.session.emit(.started(expires: nil))
        try? await Task.sleep(for: .milliseconds(100))
        rig.now = ring.addingTimeInterval(-Tuning.Wake.safetyMargin)
        try? await Task.sleep(for: .milliseconds(200))
        #expect(rig.session.wakes == 1)
        #expect(rig.sent.first?.result == .wokeAtEnd)
        #expect(await rig.heart.started == 0)
        await wake.activate()
        #expect(wake.arming.armed?.windowEnd == rig.calendar.date(byAdding: .day, value: 1, to: ring))
    }

    @Test func replacingAWindowThatIsRunningRecordsItAsEnded() async {
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
        rig.setAlarm(hour: clock.hour!, minute: clock.minute!, window: 20, id: id)
        await wake.follow()
        #expect(rig.sent.first?.result == .sessionEnded)
        #expect(rig.session.wakes == 0)
    }

    @Test func aRefusedStartShowsNotArmedAndBringsTheNudgeBack() async {
        rig.setAlarm()
        let wake = rig.coordinator()
        await wake.activate()
        let running = Task { await wake.run() }
        defer { running.cancel() }
        rig.session.emit(.ended(failed: true))
        try? await Task.sleep(for: .milliseconds(100))
        #expect(wake.armFailed)
        #expect(wake.arming.armed == nil)
        #expect(wake.plan != nil)
        #expect(await rig.nudges.reminder == .some(rig.nextSeven.addingTimeInterval(-Tuning.Wake.nudgeLead)))
    }
}
