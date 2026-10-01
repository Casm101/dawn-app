import DawnCore
import Foundation
import Testing
@testable import DawnAlarmKit

@MainActor
struct AlarmLibraryTests {
    private let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        return calendar
    }()
    private let url = FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID().uuidString).json")
    private let system = FakeAlarmScheduler()

    /// Monday 28 September 2026 at the given time, UTC.
    private func monday(_ hour: Int, _ minute: Int) -> Date {
        calendar.date(from: DateComponents(year: 2026, month: 9, day: 28, hour: hour, minute: minute))!
    }

    private func library(_ authorizer: FakeAlarmAuthorizer = FakeAlarmAuthorizer(current: .authorized)) -> AlarmLibrary {
        AlarmLibrary(file: JSONFile(url: url), sync: AlarmSystemSync(scheduler: system), authorizer: authorizer, calendar: calendar)
    }

    private func settings(_ hour: Int, _ minute: Int, days: Set<Weekday> = Weekday.weekdays) -> AlarmSettings {
        AlarmSettings(time: ClockTime(hour: hour, minute: minute)!, repeatDays: days)
    }

    @Test func theFirstEnabledAlarmAsksOnceAndIsScheduled() async throws {
        let authorizer = FakeAlarmAuthorizer()
        let alarms = library(authorizer)
        await alarms.save(settings(7, 0), id: UUID(), now: monday(8, 0))
        await alarms.save(settings(9, 30, days: Weekday.weekend), id: UUID(), now: monday(8, 0))
        #expect(await authorizer.requests == 1)
        #expect(try await system.userAlarmIDs().count == 2)
        #expect(try JSONFile<AlarmDocument>(url: url).read()?.alarms.count == 2)
    }

    @Test func aDeniedPromptSavesTheAlarmSwitchedOff() async throws {
        let alarms = library(FakeAlarmAuthorizer(answer: .denied))
        await alarms.save(settings(7, 0), id: UUID(), now: monday(8, 0))
        #expect(alarms.alarms.first?.settings.isEnabled == false)
        #expect(alarms.permission == .denied)
        #expect(try await system.userAlarmIDs().isEmpty)
    }

    @Test func anAlarmTheSystemRefusesIsSwitchedOffAndNamed() async throws {
        let alarms = library()
        await system.refuseNext()
        await alarms.save(settings(7, 0), id: UUID(), now: monday(8, 0))
        #expect(alarms.problem == .couldNotSchedule(ClockTime(hour: 7, minute: 0)!))
        #expect(alarms.alarms.first?.settings.isEnabled == false)
        #expect(try await system.userAlarmIDs().isEmpty)
    }

    @Test func aOneOffSwitchedOnTooCloseToItsTimeStaysOff() async throws {
        let alarms = library()
        let id = UUID()
        var once = settings(7, 0, days: [])
        once.isEnabled = false
        await alarms.save(once, id: id, now: monday(5, 0))
        await alarms.setEnabled(true, for: id, now: monday(6, 59))
        #expect(alarms.problem == .tooSoonToSet(ClockTime(hour: 7, minute: 0)!))
        #expect(alarms.alarms.first?.settings.isEnabled == false)
        #expect(try await system.userAlarmIDs().isEmpty)
    }

    @Test func aRepeatingAlarmTooCloseIsSavedWithANote() async throws {
        let alarms = library()
        await alarms.save(settings(7, 0), id: UUID(), now: monday(6, 59))
        #expect(alarms.problem == .mayMissNextRing(skipped: monday(7, 0), following: monday(7, 0).addingTimeInterval(86_400)))
        #expect(try await system.userAlarmIDs().count == 1)
    }

    @Test func anUnreadableFileLeavesTheSystemsAlarmsAlone() async throws {
        try Data("not json".utf8).write(to: url)
        _ = await system.plant(settings(7, 0))
        let alarms = library()
        await alarms.load(now: monday(8, 0))
        #expect(alarms.problem == .couldNotLoad)
        #expect(try await system.userAlarmIDs().count == 1)
    }

    @Test func afterAnUnreadableFileNothingIsOverwrittenOrCancelled() async throws {
        try Data("not json".utf8).write(to: url)
        _ = await system.plant(settings(7, 0))
        let alarms = library()
        await alarms.load(now: monday(8, 0))
        await alarms.save(settings(9, 0), id: UUID(), now: monday(8, 0))
        await alarms.load(now: monday(8, 5))
        #expect(alarms.problem == .couldNotLoad)
        #expect(!alarms.hasLoaded)
        #expect(try String(contentsOf: url, encoding: .utf8) == "not json")
        #expect(try await system.userAlarmIDs().count == 1)
    }

    @Test func loadingSwitchesOffAnAlarmTheSystemNoLongerHas() async throws {
        let sync = AlarmSystemSync(scheduler: system)
        let first = AlarmLibrary(file: JSONFile(url: url), sync: sync, authorizer: FakeAlarmAuthorizer(current: .authorized), calendar: calendar)
        await first.save(settings(7, 0, days: []), id: UUID(), now: monday(5, 0))
        for id in try await system.userAlarmIDs() { await system.vanish(id) }
        let relaunched = AlarmLibrary(file: JSONFile(url: url), sync: sync, authorizer: FakeAlarmAuthorizer(current: .authorized), calendar: calendar)
        #expect(!relaunched.hasLoaded)
        await relaunched.load(now: monday(8, 0))
        #expect(relaunched.hasLoaded)
        #expect(relaunched.alarms.first?.settings.isEnabled == false)
        #expect(try JSONFile<AlarmDocument>(url: url).read()?.alarms.first?.settings.isEnabled == false)
    }

    @Test func deletingRemovesTheAlarmFromTheSystemAndTheFile() async throws {
        let alarms = library()
        let id = UUID()
        await alarms.save(settings(7, 0), id: id, now: monday(8, 0))
        await alarms.delete(id, now: monday(8, 1))
        #expect(try await system.userAlarmIDs().isEmpty)
        #expect(try JSONFile<AlarmDocument>(url: url).read()?.alarms.isEmpty == true)
    }
}
