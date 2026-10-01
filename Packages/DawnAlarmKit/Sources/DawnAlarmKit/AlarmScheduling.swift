import DawnCore
import Foundation

/// The system-alarm boundary. AlarmKit sits behind it on iOS; tests use a fake.
public protocol AlarmScheduling: Sendable {
    /// A one-off alarm at an exact moment, for a computed early fire.
    func schedule(id: UUID, fireDate: Date) async throws -> ScheduledAlarm
    /// A user's alarm: its time on its days, its sound and its snooze.
    func schedule(id: UUID, alarm: AlarmDefinition) async throws
    func cancel(id: UUID) async throws
    /// The one-off alarms the system holds.
    func scheduled() async -> [ScheduledAlarm]
    /// Every alarm the system holds for this app, one-off or repeating.
    func systemIDs() async throws -> Set<UUID>
}
