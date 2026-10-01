import DawnCore
import Foundation
import Testing
@testable import DawnAlarmKit

struct AlarmSystemSyncTests {
    private let alarm = AlarmDefinition(time: ClockTime(hour: 7, minute: 0)!)

    @Test func anEnabledAlarmGetsASystemAlarm() async throws {
        let system = FakeAlarmScheduler()
        let sync = AlarmSystemSync(scheduler: system)
        try await sync.apply(alarm)
        #expect(try await system.systemIDs().count == 1)
        #expect(await system.repeating.values.first == alarm)
    }

    @Test func everyChangeCancelsTheOldSystemAlarmAndUsesANewID() async throws {
        let system = FakeAlarmScheduler()
        let sync = AlarmSystemSync(scheduler: system)
        try await sync.apply(alarm)
        let first = try await system.systemIDs()
        var edited = alarm
        edited.time = ClockTime(hour: 6, minute: 30)!
        try await sync.apply(edited)
        let second = try await system.systemIDs()
        #expect(second.count == 1)
        #expect(second.isDisjoint(with: first))
        #expect(await sync.links[alarm.id] == second.first)
    }

    @Test func aDisabledAlarmHasNoSystemAlarm() async throws {
        let system = FakeAlarmScheduler()
        let sync = AlarmSystemSync(scheduler: system)
        try await sync.apply(alarm)
        var off = alarm
        off.isEnabled = false
        try await sync.apply(off)
        #expect(try await system.systemIDs().isEmpty)
    }

    @Test func deletingAnAlarmRemovesItFromTheSystem() async throws {
        let system = FakeAlarmScheduler()
        let sync = AlarmSystemSync(scheduler: system)
        try await sync.apply(alarm)
        try await sync.remove(alarm.id)
        #expect(try await system.systemIDs().isEmpty)
    }

    @Test func anAlarmTheSystemNoLongerHasIsReportedLost() async throws {
        let system = FakeAlarmScheduler()
        let sync = AlarmSystemSync(scheduler: system)
        try await sync.apply(alarm)
        await system.vanish(try #require(await sync.links[alarm.id]))
        #expect(try await sync.reconcile(document(alarm)) == [alarm.id])
    }

    @Test func disabledAlarmsAreNeverReportedLost() async throws {
        var off = alarm
        off.isEnabled = false
        let sync = AlarmSystemSync(scheduler: FakeAlarmScheduler())
        #expect(try await sync.reconcile(document(off)).isEmpty)
    }

    @Test func systemAlarmsDawnDoesNotKnowAreCancelled() async throws {
        let system = FakeAlarmScheduler()
        let orphan = await system.plant(alarm)
        _ = try await AlarmSystemSync(scheduler: system).reconcile(AlarmDocument())
        #expect(try await !system.systemIDs().contains(orphan))
    }

    @Test func linksSurviveARelaunch() async throws {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID().uuidString).json")
        let system = FakeAlarmScheduler()
        try await AlarmSystemSync(scheduler: system, linksFile: JSONFile(url: url)).apply(alarm)
        let relaunched = AlarmSystemSync(scheduler: system, linksFile: JSONFile(url: url))
        #expect(try await relaunched.reconcile(document(alarm)).isEmpty)
        #expect(try await system.systemIDs().count == 1)
    }

    private func document(_ alarms: AlarmDefinition...) -> AlarmDocument {
        var document = AlarmDocument()
        for alarm in alarms { document.upsert(alarm, at: Date()) }
        return document
    }
}
