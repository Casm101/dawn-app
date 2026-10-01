import Foundation
@testable import DawnCore

/// Nights and naps counted back from a fixed "today", Sunday 11 October 2026 on the UTC calendar.
enum DebtFixture {
    static let calendar = SleepFixture.calendar
    static let today = calendar.date(byAdding: .day, value: 13, to: SleepFixture.monday)!
    static let hour: TimeInterval = 3600

    /// A night of `hours` asleep that ended at 07:00, `daysAgo` days before today.
    static func night(_ daysAgo: Int, hours: Double, wake: (Int, Int) = (7, 0)) -> SleepSession {
        let day = calendar.date(byAdding: .day, value: -daysAgo, to: today)!
        let end = calendar.date(bySettingHour: wake.0, minute: wake.1, second: 0, of: day)!
        let start = end.addingTimeInterval(-hours * hour)
        return SleepSession(kind: .night, source: "Fixture", samples: [
            SleepSample(start: start, end: end, stage: .unspecified, source: "Fixture"),
        ])
    }

    /// A nap of `minutes` asleep that ended at 15:00, `daysAgo` days before today.
    static func nap(_ daysAgo: Int, minutes: Double) -> SleepSession {
        let day = calendar.date(byAdding: .day, value: -daysAgo, to: today)!
        let end = calendar.date(bySettingHour: 15, minute: 0, second: 0, of: day)!
        return SleepSession(kind: .nap, source: "Fixture", samples: [
            SleepSample(start: end.addingTimeInterval(-minutes * 60), end: end, stage: .unspecified, source: "Fixture"),
        ])
    }

    static func debtHours(_ sessions: [SleepSession], need: Double = 8, on day: Date = today) -> Double? {
        SleepDebt.debt(
            days: SleepLedger.days(from: sessions, calendar: calendar), need: need * hour, through: day, calendar: calendar
        ).map { $0 / hour }
    }
}
