import Foundation
import Testing
@testable import DawnCore

/// Raw samples to an epoch's summary (WakeTF's feature extraction, MIT).
struct WakeEpochTests {
    private let start = WakeFixture.start

    private func sample(_ seconds: Double, _ g: Double, rotation: Double = 0) -> MotionSample {
        MotionSample(date: start.addingTimeInterval(seconds), acceleration: SIMD3(g, 0, 0), rotation: SIMD3(rotation, 0, 0))
    }

    @Test func featuresSummariseTheSamples() {
        let features = MotionFeatures(samples: [sample(1, 0.1, rotation: 0), sample(2, 0.5), sample(3, 0.3, rotation: 2)])
        #expect(abs(features.rms - ((0.01 + 0.25 + 0.09) / 3).squareRoot()) < 1e-9)
        #expect(features.peak == 0.5)
        #expect(features.bursts == 1)
        #expect(features.rotationDelta == 2)
        #expect(features.hasMotion)
    }

    @Test func oneSampleIsNoMotion() {
        #expect(!MotionFeatures(samples: [sample(1, 0.5)]).hasMotion)
    }

    @Test func anEpochTakesOnlyTheSamplesInsideIt() {
        let samples = [sample(25, 0.9), sample(31, 0.1), sample(45, 0.2), sample(60, 0.1), sample(61, 0.9)]
        let epoch = WakeEpoch(start: start, elapsed: 60, motion: samples, heartRates: [])
        #expect(epoch.motion.sampleCount == 3)
        #expect(epoch.motion.peak == 0.2)
    }

    @Test func heartRateIsFreshOnlyWithinFiveMinutesOfTheEpochEnd() {
        let rates = [HeartRateSample(date: start, beatsPerMinute: 60), HeartRateSample(date: start.addingTimeInterval(100), beatsPerMinute: 66)]
        let fresh = WakeEpoch(start: start, elapsed: 120, motion: [], heartRates: rates)
        #expect(fresh.heartRate.current == 66)
        #expect(fresh.heartRate.trend == .rising)
        #expect(WakeEpoch(start: start, elapsed: 420, motion: [], heartRates: rates).heartRate.current == nil)
    }

    @Test func aSteadyHeartRateIsStable() {
        let rates = (0..<4).map { HeartRateSample(date: start.addingTimeInterval(Double($0) * 30), beatsPerMinute: 58 + Double($0 % 2)) }
        #expect(HeartRateFeatures(samples: rates, now: start.addingTimeInterval(100)).trend == .stable)
    }
}
