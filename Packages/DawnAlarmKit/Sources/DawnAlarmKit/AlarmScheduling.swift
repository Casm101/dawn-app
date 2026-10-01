import DawnCore
import Foundation

/// The system-alarm boundary. AlarmKit sits behind it on iOS; tests use a fake.
public protocol AlarmScheduling: Sendable {
    /// A one-off alarm at an exact moment, for a computed early fire.
    func schedule(id: UUID, fireDate: Date) async throws -> ScheduledAlarm
    /// A user's alarm: its time on its days, its sound and its snooze.
    func schedule(id: UUID, alarm: AlarmSettings) async throws
    func cancel(id: UUID) async throws
    /// The one-off alarms the system holds.
    func scheduled() async -> [ScheduledAlarm]
    /// The user's alarms the system holds for this app, repeating or once, but not the exact-moment
    /// alarms from `schedule(id:fireDate:)`, which belong to the wake window rather than the list.
    func userAlarmIDs() async throws -> Set<UUID>
}
