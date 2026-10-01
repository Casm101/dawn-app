import Foundation

/// Every night the user rated, kept on the phone.
public struct NightRatings: Hashable, Sendable, Codable {
    public private(set) var ratings: [NightRating] = []

    public init(ratings: [NightRating] = []) {
        self.ratings = ratings
    }

    public func score(for day: CalendarDay) -> Int? {
        ratings.first { $0.day == day }?.score
    }

    /// Rates a night, replacing an earlier rating of it.
    public mutating func rate(_ day: CalendarDay, _ score: Int) {
        ratings.removeAll { $0.day == day }
        ratings.append(NightRating(day: day, score: score))
    }

    /// The night that ended at `wake`, which a day's "rate last night" asks about: the recorded night
    /// ending then, or else the evening before the wake's day.
    public static func night(endingAt wake: Date, sessions: [SleepSession], calendar: Calendar) -> CalendarDay {
        if let night = sessions.first(where: { $0.kind == .night && $0.end == wake }) {
            return CalendarDay(night.evening, calendar: calendar)
        }
        let before = calendar.date(byAdding: .day, value: -1, to: wake) ?? wake.addingTimeInterval(-24 * 3600)
        return CalendarDay(before, calendar: calendar)
    }
}
