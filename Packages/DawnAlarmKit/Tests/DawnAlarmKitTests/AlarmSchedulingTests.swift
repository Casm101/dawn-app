import DawnCore
import Foundation
import Testing
@testable import DawnAlarmKit

actor FakeAlarmScheduler: AlarmScheduling {
    private var alarms: [UUID: ScheduledAlarm] = [:]
    private(set) var repeating: [UUID: AlarmDefinition] = [:]

    func schedule(id: UUID, fireDate: Date) async throws -> ScheduledAlarm {
        let alarm = ScheduledAlarm(id: id, fireDate: fireDate)
        alarms[id] = alarm
        return alarm
    }

    func schedule(id: UUID, alarm: AlarmDefinition) async throws { repeating[id] = alarm }

    func cancel(id: UUID) async throws {
        alarms[id] = nil
        repeating[id] = nil
    }

    func scheduled() async -> [ScheduledAlarm] { Array(alarms.values) }
    func systemIDs() async throws -> Set<UUID> { Set(alarms.keys).union(repeating.keys) }

    /// Stands in for an alarm going away without Dawn asking, such as a one-off alarm that rang.
    func vanish(_ id: UUID) { repeating[id] = nil }

    /// Stands in for a system alarm Dawn has no record of.
    func plant(_ alarm: AlarmDefinition) -> UUID {
        let id = UUID()
        repeating[id] = alarm
        return id
    }
}

struct AlarmSchedulingTests {
    @Test func scheduleThenCancelLeavesNothing() async throws {
        let scheduler = FakeAlarmScheduler()
        let id = UUID()
        _ = try await scheduler.schedule(id: id, fireDate: .now.addingTimeInterval(600))
        #expect(await scheduler.scheduled().count == 1)
        try await scheduler.cancel(id: id)
        #expect(await scheduler.scheduled().isEmpty)
    }
}
