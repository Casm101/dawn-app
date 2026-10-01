import Foundation

extension Tuning {
    /// The Watch's wake window: when it is armed, how each 30-second epoch is scored, and when it fires.
    /// The scorer's shape and constants come from WakeTF (MIT), re-cut to 30-second epochs.
    public enum Wake {
        /// A window is armed only for an alarm at most this far ahead.
        public static let armingHorizon: TimeInterval = 36 * 3600
        /// A window with less than this left is not worth arming.
        public static let shortestWindow: TimeInterval = 60
        /// How long one scored epoch lasts, and how often motion is read.
        public static let epoch: TimeInterval = 30
        public static let motionInterval: TimeInterval = 0.1
        /// No sustained-movement wake before this much of the window has passed.
        public static let warmUp: TimeInterval = 60
        /// No strong-burst wake before this much of the window has passed.
        public static let burstGuard: TimeInterval = 30
        /// Epochs above the threshold in a row that count as stirring.
        public static let sustainedEpochs = 2
        /// The fallback fires this long before the window, or the session, ends.
        public static let safetyMargin: TimeInterval = 5
        /// The wake haptic repeats this often until Stop.
        public static let hapticRepeat: TimeInterval = 3
        /// The running window is checked this often, in seconds, so the deadline is never missed by much.
        public static let checkInterval = 5
        /// The longest wait, in seconds, for a replaced session to finish ending.
        public static let replaceTimeout = 3
        /// Combined score that counts as movement.
        public static let threshold = 0.38
        /// A sample this large, in g, is a strong burst; one above `burstMagnitude` counts as a burst.
        public static let strongBurst = 1.2
        public static let burstMagnitude = 0.4
        /// The peak, in g, that scores fully.
        public static let fullPeak = 0.8
        /// Bursts in an epoch that score fully.
        public static let fullBursts = 3.0
        /// Deviations above the baseline, in median absolute deviations, that score fully.
        public static let fullDeviation = 2.5
        /// Weights of the motion score's parts: steadiness, bursts, peak, rotation.
        public static let motionWeights = (rms: 0.35, bursts: 0.25, peak: 0.25, rotation: 0.15)
        /// Share of the combined score taken by heart rate when a fresh sample exists.
        public static let heartRateShare = 0.25
        /// A heart-rate rise, in beats per minute, that scores fully, its weight, and the trend's
        /// contributions.
        public static let fullRise = 15.0
        public static let riseWeight = 0.6
        public static let risingTrend = 0.4
        public static let stableTrend = 0.1
        /// A change smaller than this, in beats per minute, between samples is stable.
        public static let trendDeadband = 2.0
        /// A heart-rate sample older than this is ignored.
        public static let heartRateFreshness: TimeInterval = 300
        /// The baseline is the median of this many previous epochs, once there are `baselineMinimum`.
        public static let baselineEpochs = 8
        public static let baselineMinimum = 3
        /// The baseline before there is any history, and the smallest spread it may have.
        public static let initialMedian = 0.02
        public static let initialSpread = 0.01
        public static let smallestSpread = 0.005
        /// The bedtime nudge comes this long before the alarm when nothing is armed.
        public static let nudgeLead: TimeInterval = 9 * 3600
        /// Outcomes each device keeps.
        public static let logSize = 60
    }
}
