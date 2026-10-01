import Foundation

extension Tuning {
    /// Correcting a night and adding naps.
    public enum Edits {
        /// Edges move in steps this long.
        public static let step: TimeInterval = 5 * 60
        /// Pressing a stretch of sleep inserts an awake gap this long, once held this many seconds.
        public static let insertedGap: TimeInterval = 10 * 60
        public static let pressDuration = 0.5
        /// No stretch of sleep, and no nap, may be shorter than this.
        public static let shortestStretch: TimeInterval = 20 * 60
        /// The editing track runs this far either side of the night as Health has it.
        public static let trackMargin: TimeInterval = 2 * 3600
        /// The length an added nap starts at.
        public static let suggestedNap: TimeInterval = 30 * 60
        /// Nights and naps can be edited this many days back, today included.
        public static let days = Progress.nights
        /// The source name on sleep the user added or changed.
        public static let source = "Dawn"
    }
}
