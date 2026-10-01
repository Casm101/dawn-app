import Foundation

/// The 24 hours the Energy timeline shows: from `Tuning.Timeline.startHour` yesterday to the same
/// hour today. Once that hour has passed today, the window moves on a day so now is always inside it.
public struct TimelineWindow: Hashable, Sendable {
    public let start: Date
    public let end: Date

    public init(containing now: Date, calendar: Calendar) {
        let todayStart = calendar.date(bySettingHour: Tuning.Timeline.startHour, minute: 0, second: 0, of: now) ?? now
        let start = now >= todayStart ? todayStart : (calendar.date(byAdding: .day, value: -1, to: todayStart) ?? todayStart)
        self.start = start
        end = calendar.date(byAdding: .day, value: 1, to: start) ?? start.addingTimeInterval(Tuning.Timeline.span)
    }

    public var interval: DateInterval { DateInterval(start: start, end: end) }

    /// The share of the window, from 0 at the top to 1 at the bottom, a moment sits at.
    public func position(_ date: Date) -> Double {
        min(1, max(0, date.timeIntervalSince(start) / end.timeIntervalSince(start)))
    }

    /// Ticks every `Tuning.Timeline.tickInterval` from the top of the window to the bottom, with
    /// the whole hours marked.
    public func ticks(calendar: Calendar) -> [TimelineTick] {
        var ticks: [TimelineTick] = []
        var tick = start
        while tick <= end {
            ticks.append(TimelineTick(date: tick, isHour: calendar.component(.minute, from: tick) == 0))
            tick = tick.addingTimeInterval(Tuning.Timeline.tickInterval)
        }
        return ticks
    }

    /// The parts of the sessions' segments that fall inside the window, flagged where cut.
    public func segments(of sessions: [SleepSession]) -> [TimelineSegment] {
        sessions.flatMap(\.segments).compactMap { segment in
            let start = max(segment.start, self.start), end = min(segment.end, self.end)
            guard start < end else { return nil }
            return TimelineSegment(
                start: start, end: end,
                startsBeforeWindow: segment.start < self.start, endsAfterWindow: segment.end > self.end
            )
        }
    }
}
