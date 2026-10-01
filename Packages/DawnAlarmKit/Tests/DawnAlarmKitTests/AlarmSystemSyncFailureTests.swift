import DawnCore
import Foundation
import Testing
@testable import DawnAlarmKit

struct AlarmSystemSyncFailureTests {
    private let alarm = AlarmDefinition(
        settings: AlarmSettings(time: ClockTime(hour: 7, minute: 0)!), at: Date(), by: .phone
    )
    private let folder = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)

    private func document() -> AlarmDocument {
        var document = AlarmDocument()
        document.save(alarm.settings, id: alarm.id, at: Date(), by: .phone)
        return document
    }

    @Test func unreadableLinksCancelNothing() async throws {
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        let url = folder.appendingPathComponent("links.json")
        try Data("not json".utf8).write(to: url)
        let system = FakeAlarmScheduler()
        _ = await system.plant(alarm.settings)
        let sync = AlarmSystemSync(scheduler: system, linksFile: JSONFile(url: url))
        await #expect(throws: AlarmSyncError.linksUnreadable) { try await sync.reconcile(document()) }
        #expect(try await system.userAlarmIDs().count == 1)
    }

    @Test func aLinkThatCannotBeSavedUndoesItsSchedule() async throws {
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        let blocker = folder.appendingPathComponent("blocker")
        try Data().write(to: blocker)
        let system = FakeAlarmScheduler()
        let sync = AlarmSystemSync(scheduler: system, linksFile: JSONFile(url: blocker.appendingPathComponent("links.json")))
        await #expect(throws: (any Error).self) { try await sync.apply(alarm) }
        #expect(try await system.userAlarmIDs().isEmpty)
    }

    @Test func anExactMomentAlarmIsNeverTakenForAStray() async throws {
        let system = FakeAlarmScheduler()
        let fixed = try await system.schedule(id: UUID(), fireDate: Date().addingTimeInterval(600))
        _ = try await AlarmSystemSync(scheduler: system).reconcile(AlarmDocument())
        #expect(await system.scheduled().map(\.id) == [fixed.id])
    }
}
