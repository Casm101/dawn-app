import Foundation

/// What Home shows about sleep debt: today's value in hours, its band, and the change since yesterday.
public struct DebtSummary: Hashable, Sendable {
    public let hours: Double
    public let band: DebtBand
    /// Nil when there is no value for yesterday to compare with.
    public let change: Double?

    /// Nil when the debt window holds no sleep at all.
    public init?(sessions: [SleepSession], need: TimeInterval, now: Date, calendar: Calendar) {
        let days = SleepLedger.days(from: sessions, calendar: calendar)
        guard let today = SleepDebt.debt(days: days, need: need, through: now, calendar: calendar) else { return nil }
        // Rounded once, so the band, the number shown and the change all agree.
        let hours = Self.tenths(today)
        let yesterday = calendar.date(byAdding: .day, value: -1, to: now)
            .flatMap { SleepDebt.debt(days: days, need: need, through: $0, calendar: calendar) }
        self.hours = hours
        band = DebtBand(hours: hours)
        change = yesterday.map { hours - Self.tenths($0) }
    }

    private static func tenths(_ seconds: TimeInterval) -> Double {
        (seconds / 360).rounded() / 10
    }
}
