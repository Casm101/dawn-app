import Foundation

/// Every wake window's outcome a device has seen, newest first, each once however often it arrives.
public struct WakeLog: Hashable, Sendable, Codable {
    public private(set) var outcomes: [WakeOutcome] = []

    public init(outcomes: [WakeOutcome] = []) {
        self.outcomes = outcomes
        tidy()
    }

    /// Adds an outcome, replacing an earlier copy with the same id. Keeps the newest `Tuning.Wake.logSize`.
    public mutating func record(_ outcome: WakeOutcome) {
        outcomes.removeAll { $0.id == outcome.id }
        outcomes.append(outcome)
        tidy()
    }

    public func outcomes(for alarmID: UUID) -> [WakeOutcome] {
        outcomes.filter { $0.alarmID == alarmID }
    }

    public var latest: WakeOutcome? { outcomes.first }

    private mutating func tidy() {
        outcomes = Array(outcomes.sorted { $0.windowEnd > $1.windowEnd }.prefix(Tuning.Wake.logSize))
    }
}
