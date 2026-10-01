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

    /// The whole hours inside the window, top to bottom.
    public func hours(calendar: Calendar) -> [Date] {
        var hours: [Date] = []
        var hour = start
        while hour <= end {
            hours.append(hour)
            guard let next = calendar.date(byAdding: .hour, value: 1, to: hour) else { break }
            hour = next
        }
        return hours
    }

    /// The parts of the sessions' segments that fall inside the window.
    public func segments(of sessions: [SleepSession]) -> [SleepSegment] {
        sessions.flatMap(\.segments).compactMap { segment in
            let start = max(segment.start, self.start), end = min(segment.end, self.end)
            return start < end ? SleepSegment(start: start, end: end, samples: segment.samples) : nil
        }
    }
}
