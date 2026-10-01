/// How the user rated one night, from 0 to 10.
public struct NightRating: Hashable, Sendable, Codable {
    public static let scale = 0...10

    /// The night's evening, as Progress groups nights.
    public let day: CalendarDay
    public let score: Int

    public init(day: CalendarDay, score: Int) {
        self.day = day
        self.score = min(max(score, Self.scale.lowerBound), Self.scale.upperBound)
    }
}
