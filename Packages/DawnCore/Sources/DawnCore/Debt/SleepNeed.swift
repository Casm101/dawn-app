import Foundation

/// How much sleep this person needs. Starts at a seed, learns slowly from nights no alarm ended,
/// and stays where the user put it once they set it by hand.
public struct SleepNeed: Codable, Sendable, Hashable {
    public private(set) var value: TimeInterval
    public private(set) var isManual: Bool
    /// When the learned value last moved; the weekly cap is measured from here.
    public private(set) var learnedAt: Date?

    public init(value: TimeInterval = Tuning.Need.seed, isManual: Bool = false, learnedAt: Date? = nil) {
        self.value = Tuning.Need.range.clamped(value)
        self.isManual = isManual
        self.learnedAt = learnedAt
    }

    public mutating func set(_ value: TimeInterval) {
        self.value = Tuning.Need.range.clamped(value)
        isManual = true
    }

    public mutating func resumeLearning() {
        isManual = false
    }

    /// Moves need toward the median of the latest alarm-free nights, by at most
    /// `Tuning.Need.maxWeeklyChange` per week since it last moved.
    public mutating func learn(fromFreeNights asleep: [TimeInterval], now: Date) {
        guard !isManual, asleep.count >= Tuning.Need.minimumFreeNights else { return }
        let sample = Array(asleep.suffix(Tuning.Need.sampleNights)).sorted()
        let median = sample.count % 2 == 1
            ? sample[sample.count / 2]
            : (sample[sample.count / 2 - 1] + sample[sample.count / 2]) / 2
        let weeks = learnedAt.map { now.timeIntervalSince($0) / (7 * 86_400) } ?? 1
        let cap = Tuning.Need.maxWeeklyChange * max(0, min(weeks, 1))
        let step = max(-cap, min(cap, Tuning.Need.learningRate * (median - value)))
        guard step != 0 else { return }
        value = Tuning.Need.range.clamped(value + step)
        learnedAt = now
    }
}
