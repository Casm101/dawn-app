import Foundation

/// How much sleep this person needs. Starts at a seed, learns slowly from nights no alarm ended,
/// and stays where the user put it once they set it by hand.
public struct SleepNeed: Codable, Sendable, Hashable {
    public private(set) var value: TimeInterval
    public private(set) var isManual: Bool
    /// The value and moment at the start of the current change period; within the period need stays
    /// within `Tuning.Need.maxWeeklyChange` of this value.
    public private(set) var periodStart: Date?
    public private(set) var periodValue: TimeInterval?

    public init(value: TimeInterval = Tuning.Need.seed, isManual: Bool = false) {
        self.value = Tuning.Need.range.clamped(value)
        self.isManual = isManual
    }

    public mutating func set(_ value: TimeInterval) {
        self.value = Tuning.Need.range.clamped(value)
        isManual = true
    }

    public mutating func resumeLearning() {
        isManual = false
        periodStart = nil
        periodValue = nil
    }

    /// Moves need a tenth of the way toward the median of the latest alarm-free nights, never more
    /// than `Tuning.Need.maxWeeklyChange` away from where it stood at the start of the period.
    public mutating func learn(fromFreeNights asleep: [TimeInterval], now: Date) {
        guard !isManual, asleep.count >= Tuning.Need.minimumFreeNights else { return }
        if periodStart.map({ now.timeIntervalSince($0) >= Tuning.Need.changePeriod }) ?? true {
            periodStart = now
            periodValue = value
        }
        let anchor = periodValue ?? value
        let sample = Array(asleep.suffix(Tuning.Need.sampleNights)).sorted()
        let median = sample.count % 2 == 1
            ? sample[sample.count / 2]
            : (sample[sample.count / 2 - 1] + sample[sample.count / 2]) / 2
        let target = value + Tuning.Need.learningRate * (median - value)
        let allowed = (anchor - Tuning.Need.maxWeeklyChange)...(anchor + Tuning.Need.maxWeeklyChange)
        value = Tuning.Need.range.clamped(allowed.clamped(target))
    }
}
