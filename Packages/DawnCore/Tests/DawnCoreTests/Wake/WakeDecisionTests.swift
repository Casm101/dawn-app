import Foundation
import Testing
@testable import DawnCore

/// The window's rule, epoch by epoch.
struct WakeDecisionTests {
    private typealias W = WakeFixture

    private func run(_ epochs: [(TimeInterval, MotionFeatures)], length: TimeInterval = 1800) -> (WakeTrigger?, WakeDecision) {
        var decision = WakeDecision(length: length)
        var trigger: WakeTrigger?
        for (elapsed, motion) in epochs where trigger == nil {
            trigger = decision.add(W.epoch(elapsed, motion))
        }
        return (trigger, decision)
    }

    @Test func movementDuringTheWarmUpDoesNotWake() {
        #expect(run([(30, W.stirring), (60, W.stirring)]).0 == nil)
    }

    @Test func twoMovingEpochsInARowAfterTheWarmUpWake() {
        let (trigger, decision) = run([(30, W.still), (60, W.still), (90, W.stirring), (120, W.stirring)])
        #expect(trigger == .stirring)
        #expect(decision.epochs == 4)
        #expect(decision.peakScore > Tuning.Wake.threshold)
    }

    @Test func oneMovingEpochOnItsOwnDoesNotWake() {
        #expect(run([(90, W.stirring), (120, W.still), (150, W.stirring), (180, W.still)]).0 == nil)
    }

    @Test func aStrongBurstWakesOnceThirtySecondsHavePassed() {
        #expect(run([(30, W.burst)]).0 == nil)
        #expect(run([(30, W.still), (60, W.burst)]).0 == .strongBurst)
    }

    @Test func aStillNightWakesAtTheWindowEndLessTheMargin() {
        var decision = WakeDecision(length: 1800)
        #expect(decision.add(W.epoch(1770, W.still)) == nil)
        #expect(decision.reached(1794) == nil)
        #expect(decision.reached(1795) == .windowEnd)
    }

    @Test func aSessionShorterThanTheWindowBringsTheDeadlineForward() {
        #expect(WakeDecision(length: 1800, sessionLength: 1200).deadline == 1195)
    }

    @Test func heartRateTakingPartIsRecorded() {
        let rising = HeartRateFeatures(current: 80, trend: .rising)
        var decision = WakeDecision(length: 1800)
        var trigger: WakeTrigger?
        for elapsed in [90.0, 120] { trigger = decision.add(W.epoch(elapsed, W.stirring, heart: rising)) }
        #expect(trigger == .stirringWithHeartRate)
        #expect(decision.usedHeartRate)
    }

    @Test func aSessionAboutToEndWakesAndTheFirstTriggerStands() {
        var decision = WakeDecision(length: 1800)
        #expect(decision.expiring() == .sessionExpiring)
        #expect(decision.reached(1800) == .sessionExpiring)
    }
}
