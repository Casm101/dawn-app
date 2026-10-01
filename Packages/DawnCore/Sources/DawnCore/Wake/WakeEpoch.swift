import Foundation

/// Thirty seconds of the wake window, summarised. Only summaries like this outlive the window.
public struct WakeEpoch: Hashable, Sendable {
    /// Seconds from the window's start to the epoch's end.
    public let elapsed: TimeInterval
    public let motion: MotionFeatures
    public let heartRate: HeartRateFeatures

    public init(elapsed: TimeInterval, motion: MotionFeatures, heartRate: HeartRateFeatures) {
        self.elapsed = elapsed
        self.motion = motion
        self.heartRate = heartRate
    }

    /// The epoch ending `elapsed` seconds into a window that started at `start`, from the motion
    /// samples inside it and every heart-rate sample seen so far.
    public init(start: Date, elapsed: TimeInterval, motion: [MotionSample], heartRates: [HeartRateSample]) {
        let end = start.addingTimeInterval(elapsed)
        let from = end.addingTimeInterval(-Tuning.Wake.epoch)
        self.init(
            elapsed: elapsed,
            motion: MotionFeatures(samples: motion.filter { $0.date > from && $0.date <= end }),
            heartRate: HeartRateFeatures(samples: heartRates, now: end)
        )
    }
}
