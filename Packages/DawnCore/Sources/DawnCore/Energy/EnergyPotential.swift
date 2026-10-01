import Foundation

/// How much of their energy someone can reach today, from sleep debt alone.
public enum EnergyPotential {
    /// Whole percent: 100 with no debt, `Tuning.Energy.potentialPerDebtHour` less for each hour of
    /// debt, never below `Tuning.Energy.potentialFloor`.
    public static func percent(debtHours: Double) -> Int {
        let raw = 100 - Tuning.Energy.potentialPerDebtHour * max(0, debtHours)
        return Int(max(Tuning.Energy.potentialFloor, min(100, raw)).rounded())
    }
}
