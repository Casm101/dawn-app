import DawnCore
import Foundation
import Testing
@testable import DawnWrist

/// The running window, fed by hand the way the sensors feed it.
struct WakeMonitorTests {
    private let start = Date(timeIntervalSince1970: 1_790_000_000)
    private var plan: WakePlan { WakePlan(alarmID: UUID(), windowStart: start, windowEnd: start.addingTimeInterval(1800)) }

    /// Ten samples a second for the given seconds of the window, each `g` large.
    private func move(_ monitor: WakeMonitor, from: Double, to: Double, g: Double) async {
        for tenth in stride(from: from * 10, to: to * 10, by: 1) {
            let date = start.addingTimeInterval(tenth / 10)
            await monitor.ingest(MotionSample(date: date, acceleration: SIMD3(tenth.truncatingRemainder(dividingBy: 7) == 0 ? g * 1.6 : g * 0.6, 0, 0)))
        }
    }

    @Test func stirringAfterTheWarmUpWakesAtTheEndOfTheSecondMovingEpoch() async {
        let monitor = WakeMonitor(plan: plan, start: start)
        await move(monitor, from: 0, to: 60, g: 0.02)
        #expect(await monitor.tick(at: start.addingTimeInterval(60)) == nil)
        await move(monitor, from: 60, to: 120, g: 0.5)
        #expect(await monitor.tick(at: start.addingTimeInterval(90)) == nil)
        #expect(await monitor.tick(at: start.addingTimeInterval(120)) == .stirring)
        let outcome = await monitor.outcome(result: .wokeEarly, firedAt: start.addingTimeInterval(120))
        #expect(outcome.usedMotion)
        #expect(outcome.epochs == 4)
        #expect(outcome.heartRateSamples == 0)
    }

    @Test func aStillWristWakesAtTheWindowEndLessTheMargin() async {
        let monitor = WakeMonitor(plan: plan, start: start)
        await move(monitor, from: 0, to: 30, g: 0.01)
        #expect(await monitor.tick(at: start.addingTimeInterval(1790)) == nil)
        #expect(await monitor.tick(at: start.addingTimeInterval(1795)) == .windowEnd)
    }

    @Test func samplesAreDroppedOnceTheirEpochCloses() async {
        let monitor = WakeMonitor(plan: plan, start: start)
        await move(monitor, from: 0, to: 45, g: 0.02)
        _ = await monitor.tick(at: start.addingTimeInterval(30))
        // The sample at exactly 30 s belonged to the first epoch, so 30.1 s to 44.9 s remain.
        #expect(await monitor.heldSamples == 149)
    }

    @Test func aSessionThatEndsSoonerBringsTheDeadlineForward() async {
        let monitor = WakeMonitor(plan: plan, start: start, sessionEnds: start.addingTimeInterval(600))
        #expect(await monitor.tick(at: start.addingTimeInterval(595)) == .windowEnd)
    }

    @Test func heartRateSamplesAreCountedNotKept() async {
        let monitor = WakeMonitor(plan: plan, start: start)
        for second in 0..<20 { await monitor.ingest(HeartRateSample(date: start.addingTimeInterval(Double(second) * 10), beatsPerMinute: 58)) }
        let outcome = await monitor.outcome(result: .sessionEnded, firedAt: nil)
        #expect(outcome.heartRateSamples == 20)
        #expect(!outcome.usedMotion)
    }
}
