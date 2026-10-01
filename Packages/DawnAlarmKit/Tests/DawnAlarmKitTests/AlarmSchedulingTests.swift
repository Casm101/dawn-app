import DawnCore
import Foundation
import Testing
@testable import DawnAlarmKit

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
