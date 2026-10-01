import Foundation

extension Tuning {
    /// The Energy tab's 24-hour timeline.
    public enum Timeline {
        /// Local hour the timeline starts and ends at: from this hour yesterday to this hour today.
        public static let startHour = 18
        public static let span: TimeInterval = 24 * 3600
        /// Minor ticks every this many seconds.
        public static let tickInterval: TimeInterval = 15 * 60
        /// Where "now" sits when the timeline opens, as a share of the screen from the top.
        public static let nowAnchor = 1.0 / 3.0
    }
}
