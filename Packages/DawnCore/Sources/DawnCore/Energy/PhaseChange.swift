import Foundation

/// How far a phase's start moved since yesterday, by the clock, in whole minutes.
public enum PhaseChange: Hashable, Sendable {
    case same
    case later(minutes: Int)
    case earlier(minutes: Int)

    /// Nil when the phase did not happen yesterday.
    public init?(today: PhaseSpan, yesterday: PhaseSpan?, calendar: Calendar) {
        guard let yesterday else { return nil }
        let moved = Self.clockSeconds(today.start, calendar) - Self.clockSeconds(yesterday.start, calendar)
        // Measured round the clock, so a start moving across midnight moves a little, not a day.
        let wrapped = (moved + 36 * 3600).truncatingRemainder(dividingBy: 24 * 3600) - 12 * 3600
        let minutes = Int((wrapped / 60).rounded())
        self = minutes == 0 ? .same : minutes > 0 ? .later(minutes: minutes) : .earlier(minutes: -minutes)
    }

    private static func clockSeconds(_ date: Date, _ calendar: Calendar) -> Double {
        let parts = calendar.dateComponents([.hour, .minute, .second], from: date)
        return Double((parts.hour ?? 0) * 3600 + (parts.minute ?? 0) * 60 + (parts.second ?? 0))
    }
}
