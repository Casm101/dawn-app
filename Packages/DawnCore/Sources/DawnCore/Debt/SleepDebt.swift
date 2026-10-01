import Foundation

/// The recency-weighted shortfall against sleep need over the last `Tuning.Debt.windowNights` days.
public enum SleepDebt {
    /// Debt in seconds as of the end of `day`, or nil when the window holds no sleep at all.
    public static func debt(
        days: [Date: TimeInterval], need: TimeInterval, through day: Date, calendar: Calendar
    ) -> TimeInterval? {
        let last = calendar.startOfDay(for: day)
        let weights = DebtWeights.weights()
        var balance = 0.0
        var counted = 0
        for (index, weight) in weights.enumerated() {
            guard let date = calendar.date(byAdding: .day, value: -index, to: last),
                  let slept = days[date] else { continue }
            balance += weight * (need - slept)
            counted += 1
        }
        guard counted > 0 else { return nil }
        return max(0, Double(weights.count) * balance)
    }
}
