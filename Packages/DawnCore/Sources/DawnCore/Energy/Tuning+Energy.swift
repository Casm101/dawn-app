import Foundation

extension Tuning {
    /// The three-process alertness model (Åkerstedt & Folkard; constants as in Ingre et al. 2014)
    /// and the anchors that turn its curve into the day's phases.
    public enum Energy {
        /// Upper and lower asymptotes of the homeostatic process S.
        public static let upperAsymptote = 14.3
        public static let lowerAsymptote = 2.4
        /// Hourly decay of S while awake, and its hourly recovery rate while asleep.
        public static let wakeDecay = 0.0353
        public static let sleepRecovery = 0.3813
        /// The brake: below this level S recovers in a straight line, above it exponentially.
        public static let brakeLevel = 12.2
        /// Circadian process C: amplitude and mesor, 24-hour period.
        public static let circadianAmplitude = 2.5
        public static let circadianMesor = 0.0
        /// Ultradian process U: amplitude and mesor, 12-hour period, peaking this long after C.
        public static let ultradianAmplitude = 0.5
        public static let ultradianMesor = -0.5
        public static let ultradianLag = 3.0
        /// Sleep inertia W: the drop at waking and its hourly recovery exponent.
        public static let inertiaStart = -5.72
        public static let inertiaRecovery = -1.51
        /// The alertness scale drawn: extreme sleepiness to the upper asymptote.
        public static let scale: ClosedRange<Double> = 3.0...14.3

        /// The curve is evaluated every this many seconds.
        public static let gridStep: TimeInterval = 5 * 60
        /// C peaks this long after habitual bedtime: the published phase, 16.8 h, for a 23:00
        /// bedtime, moved with the user's own bedtime.
        public static let circadianPeakAfterBedtime: TimeInterval = 17.8 * 3600

        /// Dim-light melatonin onset, before habitual bedtime.
        public static let melatoninOnsetBeforeBed: TimeInterval = 2 * 3600
        /// The melatonin window opens this long after melatonin onset and lasts `melatoninWindow`.
        public static let melatoninWindowAfterOnset: TimeInterval = 1.05 * 3600
        public static let melatoninWindow: TimeInterval = 3600
        /// Wind-down starts no earlier than this before habitual bedtime.
        public static let windDownBeforeBed: TimeInterval = 1.5 * 3600
        /// Grogginess lasts until inertia rises above this, held between the two lengths.
        public static let grogginessEndsAbove = -0.5
        public static let grogginess: ClosedRange<TimeInterval> = (60 * 60)...(90 * 60)
        /// The afternoon dip's prior, from wake, and its width when found on the curve.
        public static let dipPrior: ClosedRange<TimeInterval> = (6.5 * 3600)...(9 * 3600)
        /// How far beyond its prior a dip, or a peak beyond its phase, may be looked for.
        public static let searchSlack: TimeInterval = 3600
        /// An extreme counts only when it stands this long clear of the search window's edges and is
        /// deeper than `flatTolerance` against the curve that far either side.
        public static let extremeSeparation: TimeInterval = 45 * 60
        public static let flatTolerance = 0.05

        /// The usual times assumed until the user gives their own.
        public static let usualBedtime = ClockTime(hour: 23, minute: 0)!
        public static let usualWakeTime = ClockTime(hour: 7, minute: 0)!
        /// Nights in the habitual window, the most recent of which count twice.
        public static let habitualWindow: TimeInterval = 7 * 24 * 3600
        public static let recentNights = 3
        /// Below this many nights in the window, the usual times are used and the schedule is learning.
        public static let minimumNights = 3
        /// Last night's wake anchors the day only if it was at most this long ago, and only a night
        /// at least `mainSleep` long counts, so an evening doze does not start a new day.
        public static let lastWakeValidity: TimeInterval = 20 * 3600
        public static let mainSleep: TimeInterval = 3 * 3600
        /// The shortest day between waking and the bedtime that ends it.
        public static let shortestDay: TimeInterval = 4 * 3600

        /// Energy potential: points lost per hour of sleep debt, and the floor.
        public static let potentialPerDebtHour = 2.1
        public static let potentialFloor = 20.0
    }
}
