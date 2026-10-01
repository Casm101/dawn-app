import Foundation

/// What the wearer's wrist and heart look like at rest tonight: the median and median absolute
/// deviation of recent motion, and the median heart rate (from WakeTF's scorer, MIT).
public struct ArousalBaseline: Hashable, Sendable {
    public let motionMedian: Double
    public let motionSpread: Double
    public let heartRate: Double?

    public init(motionMedian: Double = Tuning.Wake.initialMedian, motionSpread: Double = Tuning.Wake.initialSpread, heartRate: Double? = nil) {
        self.motionMedian = motionMedian
        self.motionSpread = motionSpread
        self.heartRate = heartRate
    }

    /// From earlier epochs, once there are enough of them; the initial baseline before that.
    public init(history: some Collection<WakeEpoch>) {
        let moving = history.filter(\.motion.hasMotion)
        guard moving.count >= Tuning.Wake.baselineMinimum else {
            self.init()
            return
        }
        let rms = moving.map(\.motion.rms).sorted()
        let median = rms[rms.count / 2]
        let deviations = rms.map { abs($0 - median) }.sorted()
        let rates = history.compactMap(\.heartRate.current).sorted()
        self.init(
            motionMedian: median,
            motionSpread: max(deviations[deviations.count / 2], Tuning.Wake.smallestSpread),
            heartRate: rates.count >= Tuning.Wake.baselineMinimum ? rates[rates.count / 2] : nil
        )
    }
}
