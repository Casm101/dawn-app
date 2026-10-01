import Foundation

/// Every alarm the user has, as one document shared by the phone and the Watch. Each change bumps the
/// revision so a copy sent to the other device is never mistaken for the one before it.
public struct AlarmDocument: Codable, Sendable, Hashable {
    public static let currentSchema = 1

    public var schemaVersion: Int
    public var revision: Int
    public var updatedAt: Date
    public var origin: Replica
    public private(set) var alarms: [AlarmDefinition]

    public init(alarms: [AlarmDefinition] = [], revision: Int = 0, updatedAt: Date = .distantPast, origin: Replica = .phone) {
        schemaVersion = Self.currentSchema
        self.revision = revision
        self.updatedAt = updatedAt
        self.origin = origin
        self.alarms = alarms
    }

    public func alarm(_ id: UUID) -> AlarmDefinition? { alarms.first { $0.id == id } }

    /// Saves settings under the id, creating the alarm or restamping only what changed.
    @discardableResult
    public mutating func save(_ settings: AlarmSettings, id: UUID, at now: Date, by origin: Replica) -> AlarmDefinition {
        var alarm = alarm(id) ?? AlarmDefinition(id: id, settings: settings, at: now, by: origin)
        alarm.apply(settings, at: now, by: origin)
        alarms.removeAll { $0.id == id }
        alarms.append(alarm)
        alarms.sort { ($0.wakeTime.value, $0.id.uuidString) < ($1.wakeTime.value, $1.id.uuidString) }
        bump(at: now, by: origin)
        return alarm
    }

    public mutating func remove(_ id: UUID, at now: Date, by origin: Replica) {
        guard alarms.contains(where: { $0.id == id }) else { return }
        alarms.removeAll { $0.id == id }
        bump(at: now, by: origin)
    }

    private mutating func bump(at now: Date, by origin: Replica) {
        revision += 1
        updatedAt = now
        self.origin = origin
    }
}
