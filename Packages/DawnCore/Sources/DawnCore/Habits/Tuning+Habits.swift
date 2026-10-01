import Foundation

extension Tuning {
    /// When each habit falls, from the day's wake, bedtime and melatonin window.
    public enum Habits {
        /// Morning light runs from waking for this long.
        public static let morningLight: TimeInterval = 3600
        /// The last caffeine, this long before the melatonin window opens.
        public static let caffeineBeforeWindow: TimeInterval = 10 * 3600
        /// Dim the lights, and start winding down, this long before bedtime.
        public static let dimLightsBeforeBed: TimeInterval = 2 * 3600
        public static let windDownBeforeBed: TimeInterval = 90 * 60
        /// A melatonin supplement, this long before bedtime.
        public static let melatoninBeforeBed: TimeInterval = 6.5 * 3600
        /// The prompt to rate last night, this long after waking.
        public static let rateAfterWake: TimeInterval = 90 * 60
        /// Every reminder Dawn schedules has an identifier starting with this.
        public static let reminderPrefix = "dawn.habit."
    }
}
