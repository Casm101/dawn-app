import Foundation

extension Tuning {
    /// Sleep need and sleep debt.
    public enum Debt {
        /// Nights in the debt window, last night included.
        public static let windowNights = 14
        /// Each night weighs this much of the night after it; over 14 nights that leaves last night
        /// about 15 percent of the total.
        public static let decay = 0.872
        /// The most a single nap adds to its day.
        public static let napCredit: TimeInterval = 90 * 60
        /// Debt band edges, in hours: under `okayBelow` is okay, over `highAbove` is high.
        public static let okayBelow = 5.0
        public static let highAbove = 10.0
    }
}
