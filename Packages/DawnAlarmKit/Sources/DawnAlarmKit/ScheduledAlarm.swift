import Foundation

/// An alarm the system has accepted, as the app remembers it.
public struct ScheduledAlarm: Hashable, Codable, Sendable, Identifiable {
    public let id: UUID
    public let fireDate: Date

    public init(id: UUID, fireDate: Date) {
        self.id = id
        self.fireDate = fireDate
    }
}
