import Foundation

/// The model's alertness at one moment of the curve.
public struct EnergyPoint: Hashable, Sendable {
    public let date: Date
    public let alertness: Double

    public init(date: Date, alertness: Double) {
        self.date = date
        self.alertness = alertness
    }
}
