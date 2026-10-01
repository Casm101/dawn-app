import Foundation

/// One phase of the day and when it runs.
public struct PhaseSpan: Hashable, Sendable, Identifiable {
    public let phase: EnergyPhase
    public let start: Date
    public let end: Date

    public init(phase: EnergyPhase, start: Date, end: Date) {
        self.phase = phase
        self.start = start
        self.end = end
    }

    public var id: EnergyPhase { phase }

    public func contains(_ date: Date) -> Bool { start <= date && date < end }
}
