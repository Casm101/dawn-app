import Foundation

/// How a night is named relative to now: tonight, last night, or the evening's weekday.
public enum NightLabel: Hashable, Sendable {
    case tonight
    case lastNight
    /// Within the last week, so the weekday alone is enough.
    case evening(Date)
    /// A week or more ago, where a weekday alone would repeat a name in the list.
    case earlier(Date)

    /// `evening` is any moment on the day the night began. Tonight is the evening of today's date, so
    /// in the morning the night just ended is last night.
    public init(evening: Date, now: Date, calendar: Calendar) {
        let tonight = calendar.startOfDay(for: now)
        let day = calendar.startOfDay(for: evening)
        if day == tonight {
            self = .tonight
        } else if let yesterday = calendar.date(byAdding: .day, value: -1, to: tonight), day == yesterday {
            self = .lastNight
        } else if let weekAgo = calendar.date(byAdding: .day, value: -6, to: tonight), day >= weekAgo {
            self = .evening(day)
        } else {
            self = .earlier(day)
        }
    }
}
