import DawnCore
import Foundation
import Testing
@testable import DawnAlarmKit

struct AlarmSystemSyncTests {
    private let alarm = AlarmDefinition(
        settings: AlarmSettings(time: ClockTime(hour: 7, minute: 0)!), at: Date(), by: .phone
    )

    private func with(_ change: (inout AlarmSettings) -> Void) -> AlarmDefinition {
        var settings = alarm.settings
        change(&settings)
        var copy = alarm
        copy.apply(settings, at: Date(), by: .phone)
        return copy
    }

    @Test func anEnabledAlarmGetsASystemAlarm() async throws {
        let system = FakeAlarmScheduler()
        let sync = AlarmSystemSync(scheduler: system)
        try await sync.apply(alarm)
        #expect(try await system.userAlarmIDs().count == 1)
        #expect(await system.repeating.values.first == alarm.settings)
    }

    @Test func everyChangeCancelsTheOldSystemAlarmAndUsesANewID() async throws {
        let system = FakeAlarmScheduler()
        let sync = AlarmSystemSync(scheduler: system)
        try await sync.apply(alarm)
        let first = try await system.userAlarmIDs()
        try await sync.apply(with { $0.time = ClockTime(hour: 6, minute: 30)! })
        let second = try await system.userAlarmIDs()
        #expect(second.count == 1)
        #expect(second.isDisjoint(with: first))
        #expect(await sync.links[alarm.id] == second.first)
    }

    @Test func aDisabledAlarmHasNoSystemAlarm() async throws {
        let system = FakeAlarmScheduler()
        let sync = AlarmSystemSync(scheduler: system)
        try await sync.apply(alarm)
        try await sync.apply(with { $0.isEnabled = false })
        #expect(try await system.userAlarmIDs().isEmpty)
    }

    @Test func deletingAnAlarmRemovesItFromTheSystem() async throws {
        let system = FakeAlarmScheduler()
        let sync = AlarmSystemSync(scheduler: system)
        try await sync.apply(alarm)
        try await sync.remove(alarm.id)
        #expect(try await system.userAlarmIDs().isEmpty)
    }

    @Test func anAlarmTheSystemNoLongerHasIsReportedLost() async throws {
        let system = FakeAlarmScheduler()
        let sync = AlarmSystemSync(scheduler: system)
        try await sync.apply(alarm)
        await system.vanish(try #require(await sync.links[alarm.id]))
        #expect(try await sync.reconcile(document(alarm)) == [alarm.id])
    }

    @Test func disabledAlarmsAreNeverReportedLost() async throws {
        let sync = AlarmSystemSync(scheduler: FakeAlarmScheduler())
        #expect(try await sync.reconcile(document(with { $0.isEnabled = false })).isEmpty)
    }

    @Test func systemAlarmsDawnDoesNotKnowAreCancelled() async throws {
        let system = FakeAlarmScheduler()
        let orphan = await system.plant(alarm.settings)
        _ = try await AlarmSystemSync(scheduler: system).reconcile(AlarmDocument())
        #expect(try await !system.userAlarmIDs().contains(orphan))
    }

    @Test func linksSurviveARelaunch() async throws {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID().uuidString).json")
        let system = FakeAlarmScheduler()
        try await AlarmSystemSync(scheduler: system, linksFile: JSONFile(url: url)).apply(alarm)
        let relaunched = AlarmSystemSync(scheduler: system, linksFile: JSONFile(url: url))
        #expect(try await relaunched.reconcile(document(alarm)).isEmpty)
        #expect(try await system.userAlarmIDs().count == 1)
    }

    @Test func aQuickOnThenOffLeavesNothingScheduled() async throws {
        let system = GatedAlarmScheduler()
        let sync = AlarmSystemSync(scheduler: system)
        let on = Task { try await sync.apply(alarm) }
        await system.waitForArrival()
        let off = Task { try await sync.apply(with { $0.isEnabled = false }) }
        try await Task.sleep(for: .milliseconds(100))
        await system.open()
        try await on.value
        try await off.value
        #expect(try await system.userAlarmIDs().isEmpty)
    }

    @Test func aLinkLeftOnASwitchedOffAlarmIsCancelled() async throws {
        let system = FakeAlarmScheduler()
        let sync = AlarmSystemSync(scheduler: system)
        try await sync.apply(alarm)
        _ = try await sync.reconcile(document(with { $0.isEnabled = false }))
        #expect(try await system.userAlarmIDs().isEmpty)
    }

    private func document(_ alarms: AlarmDefinition...) -> AlarmDocument {
        var document = AlarmDocument()
        for alarm in alarms { document.save(alarm.settings, id: alarm.id, at: Date(), by: .phone) }
        return document
    }
}
