import Foundation
import Testing
@testable import DawnAlarmKit

actor FakeAlarmScheduler: AlarmScheduling {
    private var alarms: [UUID: ScheduledAlarm] = [:]

    func schedule(id: UUID, fireDate: Date) async throws -> ScheduledAlarm {
        let alarm = ScheduledAlarm(id: id, fireDate: fireDate)
        alarms[id] = alarm
        return alarm
    }

    func cancel(id: UUID) async throws { alarms[id] = nil }
    func scheduled() async -> [ScheduledAlarm] { Array(alarms.values) }
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
