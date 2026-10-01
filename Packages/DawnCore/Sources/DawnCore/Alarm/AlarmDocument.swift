import Foundation

/// Every alarm the user has, as one document. Each change bumps the revision so a copy sent to
/// the other device is never mistaken for the one before it.
public struct AlarmDocument: Codable, Sendable, Hashable {
    public var schemaVersion: Int
    public var revision: Int
    public var updatedAt: Date
    public private(set) var alarms: [AlarmDefinition]

    public init(alarms: [AlarmDefinition] = [], revision: Int = 0, updatedAt: Date = .distantPast) {
        schemaVersion = 1
        self.revision = revision
        self.updatedAt = updatedAt
        self.alarms = alarms
    }

    public func alarm(_ id: UUID) -> AlarmDefinition? { alarms.first { $0.id == id } }

    /// Adds the alarm, or replaces the one with the same id, keeping alarms in time order.
    public mutating func upsert(_ alarm: AlarmDefinition, at now: Date) {
        var alarm = alarm
        alarm.updatedAt = now
        alarms.removeAll { $0.id == alarm.id }
        alarms.append(alarm)
        alarms.sort { ($0.time, $0.id.uuidString) < ($1.time, $1.id.uuidString) }
        bump(at: now)
    }

    public mutating func remove(_ id: UUID, at now: Date) {
        guard alarms.contains(where: { $0.id == id }) else { return }
        alarms.removeAll { $0.id == id }
        bump(at: now)
    }

    private mutating func bump(at now: Date) {
        revision += 1
        updatedAt = now
    }
}
