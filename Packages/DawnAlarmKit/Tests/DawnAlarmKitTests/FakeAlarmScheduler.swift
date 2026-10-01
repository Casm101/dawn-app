import DawnCore
import Foundation
@testable import DawnAlarmKit

/// Holds alarms in memory the way the system would, and can refuse or lose one on request.
actor FakeAlarmScheduler: AlarmScheduling {
    private var alarms: [UUID: ScheduledAlarm] = [:]
    private(set) var repeating: [UUID: AlarmSettings] = [:]
    /// One-off alarms at exact moments with a user's settings, standing in for a skipped ring.
    private(set) var fixed: [UUID: (date: Date, alarm: AlarmSettings)] = [:]
    private var failNext = false

    func schedule(id: UUID, fireDate: Date) async throws -> ScheduledAlarm {
        let alarm = ScheduledAlarm(id: id, fireDate: fireDate)
        alarms[id] = alarm
        return alarm
    }

    func schedule(id: UUID, alarm: AlarmSettings) async throws {
        if failNext {
            failNext = false
            throw CocoaError(.featureUnsupported)
        }
        repeating[id] = alarm
    }

    func schedule(id: UUID, at date: Date, alarm: AlarmSettings) async throws {
        fixed[id] = (date, alarm)
    }

    /// Makes the next schedule call fail, as when the system refuses an alarm.
    func refuseNext() { failNext = true }

    func cancel(id: UUID) async throws {
        alarms[id] = nil
        repeating[id] = nil
        fixed[id] = nil
    }

    func scheduled() async -> [ScheduledAlarm] { Array(alarms.values) }
    func userAlarmIDs() async throws -> Set<UUID> { Set(repeating.keys) }

    /// Stands in for an alarm going away without Dawn asking, such as a one-off alarm that rang.
    func vanish(_ id: UUID) { repeating[id] = nil }

    /// Stands in for a system alarm Dawn has no record of.
    func plant(_ alarm: AlarmSettings) -> UUID {
        let id = UUID()
        repeating[id] = alarm
        return id
    }
}
