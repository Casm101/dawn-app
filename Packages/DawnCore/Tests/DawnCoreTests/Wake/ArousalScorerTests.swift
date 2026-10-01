import Foundation
import Testing
@testable import DawnCore

/// WakeTF's scorer tests (MIT), on 30-second epochs.
struct ArousalScorerTests {
    private typealias W = WakeFixture

    @Test func aStillWristScoresLow() {
        #expect(ArousalScorer.score(W.epoch(200, W.still), baseline: W.quiet).combined < 0.3)
    }

    @Test func clearMovementScoresAboveTheThreshold() {
        #expect(ArousalScorer.score(W.epoch(200, W.stirring), baseline: W.quiet).combined > Tuning.Wake.threshold)
    }

    @Test func aStaleHeartRateIsIgnored() {
        let old = HeartRateFeatures(samples: [HeartRateSample(date: W.start, beatsPerMinute: 85)], now: W.start.addingTimeInterval(400))
        let score = ArousalScorer.score(W.epoch(400, W.motion(rms: 0.1, peak: 0.3, bursts: 1), heart: old), baseline: W.quiet)
        #expect(score.heartRate == 0)
        #expect(!score.usedHeartRate)
    }

    @Test func aFreshRisingHeartRateAddsToTheScore() {
        let rising = HeartRateFeatures(current: 80, trend: .rising)
        let baseline = ArousalBaseline(motionMedian: 0.02, motionSpread: 0.01, heartRate: 62)
        let score = ArousalScorer.score(W.epoch(200, W.motion(rms: 0.15, peak: 0.4, bursts: 2), heart: rising), baseline: baseline)
        #expect(score.heartRate > 0)
        #expect(score.usedHeartRate)
        #expect(score.combined > score.motion * (1 - Tuning.Wake.heartRateShare))
    }

    @Test func withoutMotionNothingScoresEvenWithHeartRate() {
        let rising = HeartRateFeatures(current: 90, trend: .rising)
        let score = ArousalScorer.score(W.epoch(200, MotionFeatures(), heart: rising), baseline: W.quiet)
        #expect(score.combined == 0)
    }

    @Test func aLargeMovementIsAStrongBurst() {
        #expect(ArousalScorer.score(W.epoch(40, W.burst), baseline: W.quiet).isStrongBurst)
        #expect(!ArousalScorer.score(W.epoch(40, W.stirring), baseline: W.quiet).isStrongBurst)
    }

    @Test func theBaselineFollowsRecentEpochsOnceThereAreThree() {
        let history = (0..<5).map { W.epoch(Double($0 + 1) * 30, W.motion(rms: 0.02 + Double($0) * 0.001, peak: 0.05)) }
        let baseline = ArousalBaseline(history: history)
        #expect(baseline.motionMedian == 0.022)
        #expect(baseline.motionSpread >= Tuning.Wake.smallestSpread)
        #expect(ArousalBaseline(history: history.prefix(2)) == ArousalBaseline())
    }
}
