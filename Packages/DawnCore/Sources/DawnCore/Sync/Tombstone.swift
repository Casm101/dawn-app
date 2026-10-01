import Foundation

/// A record that an alarm was deleted, kept so the other device deletes it too instead of bringing
/// it back.
public struct Tombstone: Codable, Sendable, Hashable {
    public let id: UUID
    public let deletedAt: Date
    public let origin: Replica

    public init(id: UUID, deletedAt: Date, origin: Replica) {
        self.id = id
        self.deletedAt = deletedAt
        self.origin = origin
    }
}
