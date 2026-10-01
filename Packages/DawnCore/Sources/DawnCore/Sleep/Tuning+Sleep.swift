import Foundation

extension Tuning {
    /// How Health samples become sessions, and how a nap is told from a night.
    public enum Sleep {
        /// Samples closer together than this belong to the same session.
        public static let sessionGap: TimeInterval = 3 * 3600
        /// A daytime session shorter than this is a nap.
        public static let napMaxSpan: TimeInterval = 2.5 * 3600
        /// Local hour at which the day starts for nap purposes; a session starting earlier is night sleep.
        public static let daytimeStartHour = 6
        /// Local hour at which the evening starts; a nap ends no later than this.
        public static let eveningStartHour = 18
        /// How far back Home looks for last night and recent naps.
        public static let recentWindow: TimeInterval = 48 * 3600
        /// A night is named after the evening it began: its start, moved back by this much, gives the day.
        public static let nightNameShift: TimeInterval = 12 * 3600
        /// How many days of Health samples the importer reads.
        public static let importDays = 15
    }
}
