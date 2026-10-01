import DawnCore
import Foundation
import Testing
@testable import DawnAlarmKit

@MainActor
struct AlarmLibrarySyncTests {
    private let url = FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID().uuidString).json")
    private let system = FakeAlarmScheduler()
    private let now = Date(timeIntervalSinceReferenceDate: 812_000_000)

    private func library() -> AlarmLibrary {
        AlarmLibrary(file: JSONFile(url: url), sync: AlarmSystemSync(scheduler: system), authorizer: FakeAlarmAuthorizer(current: .authorized))
    }

    private func settings(_ hour: Int) -> AlarmSettings {
        AlarmSettings(time: ClockTime(hour: hour, minute: 0)!, repeatDays: Set(Weekday.allCases))
    }

    @Test func everyLocalChangeIsReported() async {
        let alarms = library()
        var reported = 0
        alarms.onLocalChange = { reported += 1 }
        let id = UUID()
        await alarms.save(settings(7), id: id, now: now)
        await alarms.delete(id, now: now)
        #expect(reported == 2)
    }

    @Test func aTimeChangedOnTheWatchMovesTheSystemAlarm() async throws {
        let alarms = library()
        let id = UUID()
        await alarms.save(settings(7), id: id, now: now)
        let before = try await system.userAlarmIDs()
        var remote = alarms.document
        remote.save(settings(6), id: id, at: now.addingTimeInterval(60), by: .watch)
        _ = await alarms.applyRemote(remote, at: now)
        let after = try await system.userAlarmIDs()
        #expect(after.count == 1)
        #expect(after.isDisjoint(with: before))
        #expect(await system.repeating.values.first?.time == ClockTime(hour: 6, minute: 0)!)
        #expect(try JSONFile<AlarmDocument>(url: url).read()?.alarm(id)?.settings.time == ClockTime(hour: 6, minute: 0)!)
    }

    @Test func anAlarmDeletedOnTheWatchLeavesTheSystem() async throws {
        let alarms = library()
        let id = UUID()
        await alarms.save(settings(7), id: id, now: now)
        var remote = alarms.document
        remote.remove(id, at: now.addingTimeInterval(60), by: .watch)
        _ = await alarms.applyRemote(remote, at: now)
        #expect(alarms.alarms.isEmpty)
        #expect(try await system.userAlarmIDs().isEmpty)
    }

    @Test func anUnchangedAlarmKeepsItsSystemAlarm() async throws {
        let alarms = library()
        let kept = UUID(), changed = UUID()
        await alarms.save(settings(7), id: kept, now: now)
        await alarms.save(settings(9), id: changed, now: now)
        let keptLink = await alarms.systemLink(for: kept)
        var remote = alarms.document
        remote.save(settings(10), id: changed, at: now.addingTimeInterval(60), by: .watch)
        _ = await alarms.applyRemote(remote, at: now)
        #expect(await alarms.systemLink(for: kept) == keptLink)
    }

    @Test func aCopyForSendingCarriesAHigherRevisionAndIsSaved() throws {
        let alarms = library()
        let before = alarms.document.revision
        let sent = alarms.documentForSending(at: now)
        #expect(sent.revision == before + 1)
        #expect(try JSONFile<AlarmDocument>(url: url).read()?.revision == sent.revision)
    }
}
