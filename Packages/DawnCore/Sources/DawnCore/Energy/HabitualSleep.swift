import Foundation

/// The bed and wake times the day's schedule is anchored on: the recent nights' usual times, or the
/// user's own while there are too few nights.
public struct HabitualSleep: Hashable, Sendable {
    public let bedtime: ClockTime
    public let wakeTime: ClockTime
    /// True while there are too few recent nights and the user's own times stand in.
    public let isLearning: Bool

    public init(sessions: [SleepSession], usual: UsualSleep, now: Date, calendar: Calendar) {
        let since = now.addingTimeInterval(-Tuning.Energy.habitualWindow)
        let nights = sessions.filter { $0.kind == .night && $0.end <= now && $0.end > since }.sorted { $0.end < $1.end }
        guard nights.count >= Tuning.Energy.minimumNights else {
            bedtime = usual.bedtime
            wakeTime = usual.wakeTime
            isLearning = true
            return
        }
        let recent = nights.count - Tuning.Energy.recentNights
        let weights = nights.indices.map { $0 >= recent ? 2.0 : 1.0 }
        bedtime = ClockTime.median(nights.map { ClockTime($0.start, calendar: calendar) }, weights: weights)
        wakeTime = ClockTime.median(nights.map { ClockTime($0.end, calendar: calendar) }, weights: weights)
        isLearning = false
    }

    /// How long the habitual night lasts, bedtime to wake time.
    public var nightLength: TimeInterval {
        TimeInterval((wakeTime.minutesSinceMidnight - bedtime.minutesSinceMidnight + 1440) % 1440) * 60
    }
}
