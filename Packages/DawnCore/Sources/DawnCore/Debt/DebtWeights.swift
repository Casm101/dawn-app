import Foundation

/// Recency weights over the debt window: index 0 is last night. They sum to one.
public enum DebtWeights {
    public static func weights(count: Int = Tuning.Debt.windowNights) -> [Double] {
        let raw = (0..<count).map { Tuning.Debt.lastNightWeight * pow(Tuning.Debt.decay, Double($0)) }
        let total = raw.reduce(0, +)
        return raw.map { $0 / total }
    }
}
