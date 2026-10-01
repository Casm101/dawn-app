import Foundation

/// Sleep per day: the night that ended that day plus that day's naps, each nap capped at
/// `Tuning.Debt.napCredit`. A day with no night has no entry, so it counts as neither shortfall
/// nor surplus.
public enum SleepLedger {
    public static func days(from sessions: [SleepSession], calendar: Calendar) -> [Date: TimeInterval] {
        var nights: [Date: TimeInterval] = [:]
        var naps: [Date: TimeInterval] = [:]
        for session in sessions {
            let day = calendar.startOfDay(for: session.end)
            switch session.kind {
            case .night: nights[day, default: 0] += session.asleep
            case .nap: naps[day, default: 0] += min(session.asleep, Tuning.Debt.napCredit)
            }
        }
        return nights.reduce(into: [:]) { days, entry in
            days[entry.key] = entry.value + (naps[entry.key] ?? 0)
        }
    }
}
