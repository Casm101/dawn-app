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
    /// Deleted alarms, so the other device deletes them too rather than bringing them back.
    public private(set) var tombstones: [Tombstone]

    public init(
        alarms: [AlarmDefinition] = [], tombstones: [Tombstone] = [],
        revision: Int = 0, updatedAt: Date = .distantPast, origin: Replica = .phone
    ) {
        schemaVersion = Self.currentSchema
        self.revision = revision
        self.updatedAt = updatedAt
        self.origin = origin
        self.alarms = alarms.sorted(by: Self.inTimeOrder)
        self.tombstones = tombstones.sorted { $0.id.uuidString < $1.id.uuidString }
    }

    enum CodingKeys: String, CodingKey {
        case schemaVersion, revision, updatedAt, origin, alarms, tombstones
    }

    /// Reads documents written before deletions were recorded, which have no tombstones.
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            alarms: try container.decode([AlarmDefinition].self, forKey: .alarms),
            tombstones: try container.decodeIfPresent([Tombstone].self, forKey: .tombstones) ?? [],
            revision: try container.decode(Int.self, forKey: .revision),
            updatedAt: try container.decode(Date.self, forKey: .updatedAt),
            origin: try container.decode(Replica.self, forKey: .origin)
        )
        schemaVersion = try container.decode(Int.self, forKey: .schemaVersion)
    }

    public func alarm(_ id: UUID) -> AlarmDefinition? { alarms.first { $0.id == id } }
    public func tombstone(_ id: UUID) -> Tombstone? { tombstones.first { $0.id == id } }

    /// Saves settings under the id, creating the alarm or restamping only what changed.
    @discardableResult
    public mutating func save(_ settings: AlarmSettings, id: UUID, at now: Date, by origin: Replica) -> AlarmDefinition {
        var alarm = alarm(id) ?? AlarmDefinition(id: id, settings: settings, at: now, by: origin)
        alarm.apply(settings, at: now, by: origin)
        alarms.removeAll { $0.id == id }
        alarms.append(alarm)
        alarms.sort(by: Self.inTimeOrder)
        tombstones.removeAll { $0.id == id }
        bump(at: now, by: origin)
        return alarm
    }

    public mutating func remove(_ id: UUID, at now: Date, by origin: Replica) {
        guard alarms.contains(where: { $0.id == id }) else { return }
        alarms.removeAll { $0.id == id }
        tombstones.removeAll { $0.id == id }
        tombstones.append(Tombstone(id: id, deletedAt: now, origin: origin))
        bump(at: now, by: origin)
    }

    /// Marks a new copy for sending: a higher revision, so even an unchanged document is delivered.
    public mutating func bump(at now: Date, by origin: Replica) {
        revision += 1
        updatedAt = max(updatedAt, now)
        self.origin = origin
    }

    /// True when both hold the same alarms and deletions, whatever their revisions.
    public func sameContent(as other: AlarmDocument) -> Bool {
        alarms == other.alarms && tombstones == other.tombstones
    }

    private static func inTimeOrder(_ lhs: AlarmDefinition, _ rhs: AlarmDefinition) -> Bool {
        (lhs.wakeTime.value, lhs.id.uuidString) < (rhs.wakeTime.value, rhs.id.uuidString)
    }
}
