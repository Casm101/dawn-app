import Foundation

extension Tuning {
    /// How sleep need starts and how it learns.
    public enum Need {
        public static let seed: TimeInterval = 8 * 3600 + 15 * 60
        public static let range: ClosedRange<TimeInterval> = 5 * 3600...11.5 * 3600
        /// Alarm-free nights needed before need moves at all.
        public static let minimumFreeNights = 3
        /// How many of the latest alarm-free nights the median is taken over.
        public static let sampleNights = 10
        /// Share of the gap between need and the median closed at each update.
        public static let learningRate = 0.1
        /// The most need moves in a week.
        public static let maxWeeklyChange: TimeInterval = 10 * 60
        /// A night counts as ended by an alarm when the wake falls this close to an alarm's time.
        public static let alarmWakeTolerance: TimeInterval = 30 * 60
        /// The length of the period `maxWeeklyChange` applies to.
        public static let changePeriod: TimeInterval = 7 * 86_400
        /// One step of the Profile stepper.
        public static let manualStep: TimeInterval = 15 * 60
        /// A value set by hand lands on a multiple of this.
        public static let manualRounding: TimeInterval = 5 * 60
    }
}
