import Foundation

/// The system-alarm boundary. AlarmKit sits behind it on iOS; tests use a fake.
public protocol AlarmScheduling: Sendable {
    func schedule(id: UUID, fireDate: Date) async throws -> ScheduledAlarm
    func cancel(id: UUID) async throws
    func scheduled() async -> [ScheduledAlarm]
}
