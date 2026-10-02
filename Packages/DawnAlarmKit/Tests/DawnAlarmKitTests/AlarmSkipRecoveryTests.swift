import DawnCore
import Foundation
import Testing
@testable import DawnAlarmKit

/// Stood-down rings coming back when the phone app runs only in the background, or after their
/// record was lost.
@MainActor
struct AlarmSkipRecoveryTests {
    private let folder = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    private let system = FakeAlarmScheduler()
    private let clock = TestClock(DayFixture.at(1, "06:41"))
    private let first = UUID(), second = UUID()

    private func library() -> AlarmLibrary {
        try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        return AlarmLibrary(
            file: JSONFile(url: folder.appending(path: "alarms.json")),
            sync: AlarmSystemSync(
                scheduler: system, linksFile: JSONFile(url: folder.appending(path: "links.json")),
                skipsFile: JSONFile(url: folder.appending(path: "skips.json")),
                clock: { [clock] in clock.now }, calendar: DayFixture.calendar
            ),
            authorizer: FakeAlarmAuthorizer(current: .authorized), calendar: DayFixture.calendar
        )
    }

    private func weekdays(at hour: Int, _ minute: Int) -> AlarmSettings {
        AlarmSettings(time: ClockTime(hour: hour, minute: minute)!, repeatDays: Weekday.weekdays)
    }

    private func earlyWake(_ id: UUID, ring: Date) -> WakeOutcome {
        WakeOutcome(alarmID: id, windowStart: ring.addingTimeInterval(-1800), windowEnd: ring, result: .wokeEarly, trigger: .stirring)
    }

    @Test func aPassedStandDownComesBackWhenTheWatchWakesThePhoneForAnotherRing() async {
        let alarms = library()
        await alarms.save(weekdays(at: 7, 0), id: first, now: DayFixture.at(0, "20:00"))
        await alarms.save(weekdays(at: 7, 30), id: second, now: DayFixture.at(0, "20:00"))
        await alarms.received(earlyWake(first, ring: DayFixture.at(1, "07:00")), at: clock.now)
        // A day later, with the app never opened, the Watch's message is the only run.
        clock.now = DayFixture.at(2, "07:10")
        await alarms.received(earlyWake(second, ring: DayFixture.at(2, "07:30")), at: clock.now)
        let days = await system.repeating.values.map(\.repeatDays)
        #expect(days.contains(Weekday.weekdays))
        #expect(days.contains(Weekday.weekdays.subtracting([.wednesday])))
        #expect(await system.fixed.count == 1)
    }

    @Test func anUnreadableRecordOfStandDownsPutsEveryRepeatingAlarmBackOnAllItsDays() async throws {
        let alarms = library()
        await alarms.save(weekdays(at: 7, 0), id: first, now: DayFixture.at(0, "20:00"))
        await alarms.received(earlyWake(first, ring: DayFixture.at(1, "07:00")), at: clock.now)
        #expect(await system.fixed.count == 1)
        try Data("not json".utf8).write(to: folder.appending(path: "skips.json"))
        let relaunched = library()
        await relaunched.load(now: clock.now)
        #expect(await system.repeating.values.map(\.repeatDays) == [Weekday.weekdays])
        #expect(await system.fixed.isEmpty)
    }
}
