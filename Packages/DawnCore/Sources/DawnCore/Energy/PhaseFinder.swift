import Foundation

/// Finds the curve's peaks and dips inside the windows the priors give. A stretch that only rises
/// or falls, or is too flat, has no extreme, and the caller falls back to its prior.
public enum PhaseFinder {
    public static func highest(in curve: EnergyCurve, within window: DateInterval) -> Date? {
        extreme(in: curve, within: window, sign: 1)
    }

    public static func lowest(in curve: EnergyCurve, within window: DateInterval) -> Date? {
        extreme(in: curve, within: window, sign: -1)
    }

    /// The most pronounced point that beats every point within `extremeSeparation` either side and
    /// stands more than `flatTolerance` above (or below) the curve at that distance.
    private static func extreme(in curve: EnergyCurve, within window: DateInterval, sign: Double) -> Date? {
        let points = curve.points.filter { window.contains($0.date) }
        let reach = Int((Tuning.Energy.extremeSeparation / Tuning.Energy.gridStep).rounded())
        guard points.count > 2 * reach else { return nil }
        var best: (date: Date, value: Double)?
        for index in reach..<(points.count - reach) {
            let value = sign * points[index].alertness
            let around = points[(index - reach)...(index + reach)].map { sign * $0.alertness }
            guard value >= around.max() ?? value else { continue }
            let edge = max(sign * points[index - reach].alertness, sign * points[index + reach].alertness)
            guard value - edge > Tuning.Energy.flatTolerance else { continue }
            if best.map({ value > $0.value }) ?? true { best = (points[index].date, value) }
        }
        return best?.date
    }
}
