import Foundation

extension Tuning {
    /// When each habit falls, from the day's wake, bedtime and melatonin window.
    public enum Habits {
        /// Morning light runs from waking for this long.
        public static let morningLight: TimeInterval = 3600
        /// The last caffeine, this long before the melatonin window opens.
        public static let caffeineBeforeWindow: TimeInterval = 10 * 3600
        /// Dim the lights this long before bedtime. Winding down starts at the energy schedule's
        /// `Tuning.Energy.windDownBeforeBed`, so its chip and its band agree.
        public static let dimLightsBeforeBed: TimeInterval = 2 * 3600
        /// A melatonin supplement, this long before bedtime.
        public static let melatoninBeforeBed: TimeInterval = 6.5 * 3600
        /// The prompt to rate last night, this long after waking.
        public static let rateAfterWake: TimeInterval = 90 * 60
        /// Every reminder Dawn schedules has an identifier starting with this.
        public static let reminderPrefix = "dawn.habit."
        /// Reminders are planned this many days ahead, so they keep coming while Dawn stays closed.
        /// Six habits a day keeps this well under the system's 64 pending notifications.
        public static let planDays = 7
        /// Which habits already had their reminder is remembered for this many days back.
        public static let firedMemoryDays = 2
    }
}
