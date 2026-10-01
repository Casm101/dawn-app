import Foundation

/// What Home shows: the latest night and any naps inside `Tuning.Sleep.recentWindow`.
public struct RecentSleep: Hashable, Sendable {
    public let lastNight: SleepSession?
    /// Newest first.
    public let naps: [SleepSession]

    public init(sessions: [SleepSession], now: Date) {
        let cutoff = now.addingTimeInterval(-Tuning.Sleep.recentWindow)
        let recent = sessions.filter { $0.end > cutoff && $0.start <= now }
        lastNight = recent.filter { $0.kind == .night }.max { $0.end < $1.end }
        naps = recent.filter { $0.kind == .nap }.sorted { $0.start > $1.start }
    }

    public var isEmpty: Bool { lastNight == nil && naps.isEmpty }
}
