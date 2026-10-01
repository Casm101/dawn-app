import Foundation

/// What heart rate says at the end of an epoch (from WakeTF's heart-rate monitor, MIT). Passive
/// samples are sparse without a workout session, so this is often empty.
public struct HeartRateFeatures: Hashable, Sendable, Codable {
    /// The latest sample, when it is fresh.
    public var current: Double?
    public var trend: HeartRateTrend

    public init(current: Double? = nil, trend: HeartRateTrend = .unknown) {
        self.current = current
        self.trend = trend
    }

    /// From the samples seen so far, as of `now`: the latest one if fresh, and the mean of the last
    /// three changes as the trend.
    public init(samples: [HeartRateSample], now: Date) {
        let recent = samples.filter { $0.date <= now }.sorted { $0.date < $1.date }
        guard let latest = recent.last, now.timeIntervalSince(latest.date) < Tuning.Wake.heartRateFreshness else {
            self.init()
            return
        }
        let values = recent.suffix(4).map(\.beatsPerMinute)
        let changes = zip(values, values.dropFirst()).map { $1 - $0 }
        let trend: HeartRateTrend
        if changes.isEmpty {
            trend = .unknown
        } else {
            let mean = changes.reduce(0, +) / Double(changes.count)
            trend = mean > Tuning.Wake.trendDeadband ? .rising : mean < -Tuning.Wake.trendDeadband ? .falling : .stable
        }
        self.init(current: latest.beatsPerMinute, trend: trend)
    }

    public var isFresh: Bool { current != nil }
}
