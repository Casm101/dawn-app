extension Tuning {
    /// The Progress tab's Sleep Times chart.
    public enum Progress {
        /// Evenings shown, tonight included.
        public static let nights = 14
        public static let nightsPerPage = 7
        /// The axis span always shown, in hours after noon on the evening's day: 21:00 to 09:00.
        public static let defaultAxis: ClosedRange<Double> = 9...21
        /// Where tonight's placeholder sits before any sleep, in the same hours: 23:00 to 07:00.
        public static let placeholder: ClosedRange<Double> = 11...19
    }
}
