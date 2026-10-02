import Foundation
@testable import DawnCore

/// Epochs and samples for the wake tests, on the UTC sleep fixture's calendar.
enum WakeFixture {
    static let start = SleepFixture.at(1, "06:30")

    static func motion(rms: Double, peak: Double, bursts: Int = 0, rotation: Double? = nil) -> MotionFeatures {
        MotionFeatures(rms: rms, variance: rms / 2, peak: peak, bursts: bursts, rotationDelta: rotation ?? rms * 1.5, sampleCount: 300)
    }

    /// An epoch ending `elapsed` seconds into the window.
    static func epoch(_ elapsed: TimeInterval, _ motion: MotionFeatures, heart: HeartRateFeatures = HeartRateFeatures()) -> WakeEpoch {
        WakeEpoch(elapsed: elapsed, motion: motion, heartRate: heart)
    }

    static let still = motion(rms: 0.02, peak: 0.05)
    static let stirring = motion(rms: 0.4, peak: 0.9, bursts: 4)
    static let burst = motion(rms: 0.3, peak: 1.5, bursts: 2)

    /// A baseline from a quiet stretch, as WakeTF's tests use.
    static let quiet = ArousalBaseline(motionMedian: 0.02, motionSpread: 0.01)
}
