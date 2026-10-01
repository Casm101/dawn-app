import DawnCore
import Foundation
import Testing
@testable import DawnAlarmKit

/// A stood-down ring meets edits, deletions, lost records and stale news.
@MainActor
struct AlarmStandDownEditTests {
    private let url = FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID().uuidString).json")
    private let system = FakeAlarmScheduler()
    private let clock = TestClock(DayFixture.at(1, "06:41"))
    private let id = UUID()

    private func library(skips: URL? = nil) -> AlarmLibrary {
        AlarmLibrary(
            file: JSONFile(url: url),
            sync: AlarmSystemSync(
                scheduler: system, skipsFile: skips.map { JSONFile(url: $0) }, clock: { [clock] in clock.now }, calendar: DayFixture.calendar
            ),
            authorizer: FakeAlarmAuthorizer(current: .authorized), calendar: DayFixture.calendar
        )
    }

    private func settings(_ days: Set<Weekday>, hour: Int = 7, minute: Int = 0) -> AlarmSettings {
        AlarmSettings(time: ClockTime(hour: hour, minute: minute)!, repeatDays: days)
    }

    /// Day 1 is a Tuesday; its 07:00 ring is the one woken for.
    private var earlyWake: WakeOutcome {
        WakeOutcome(alarmID: id, windowStart: DayFixture.at(1, "06:30"), windowEnd: DayFixture.at(1, "07:00"), result: .wokeEarly)
    }

    @Test func aTimeMovedAfterTheEarlyWakeRingsThatDayAtItsNewTime() async {
        let alarms = library()
        await alarms.save(settings(Weekday.weekdays), id: id, now: DayFixture.at(0, "20:00"))
        await alarms.received(earlyWake, at: clock.now)
        await alarms.save(settings(Weekday.weekdays, hour: 8, minute: 30), id: id, now: DayFixture.at(1, "06:50"))
        #expect(await system.repeating.values.first?.repeatDays == Weekday.weekdays)
        #expect(await system.fixed.isEmpty)
    }

    @Test func aOneOffMovedAfterTheEarlyWakeIsScheduledAgainAndStaysOn() async throws {
        let alarms = library()
        await alarms.save(settings([]), id: id, now: DayFixture.at(0, "20:00"))
        await alarms.received(earlyWake, at: clock.now)
        await alarms.save(settings([], hour: 8, minute: 30), id: id, now: DayFixture.at(1, "06:50"))
        #expect(try await system.userAlarmIDs().count == 1)
        clock.now = DayFixture.at(1, "07:30")
        await alarms.load(now: clock.now)
        #expect(alarms.alarms.first?.settings.isEnabled == true)
    }

    @Test func aLostStandInIsCancelledWhileTheOwnedOneAndOtherExactAlarmsStay() async {
        let alarms = library()
        await alarms.save(settings(Weekday.weekdays), id: id, now: DayFixture.at(0, "20:00"))
        let lostAt = DayFixture.at(3, "07:00")
        let lost = await system.plantFixed(id: BackstopSkip.standInID(for: id, at: lostAt), at: lostAt, alarm: settings([]))
        let unrelated = await system.plantFixed(at: DayFixture.at(4, "06:12"), alarm: settings([]))
        await alarms.received(earlyWake, at: clock.now)
        await alarms.load(now: clock.now)
        let fixed = await system.fixed
        #expect(fixed[lost] == nil)
        #expect(fixed[unrelated] != nil)
        #expect(fixed.count == 2)
    }

    @Test func aDeletionFromTheWatchDropsNextWeeksStandIn() async {
        let alarms = library()
        await alarms.save(settings(Weekday.weekdays), id: id, now: DayFixture.at(0, "20:00"))
        await alarms.received(earlyWake, at: clock.now)
        var remote = alarms.document
        remote.remove(id, at: DayFixture.at(1, "06:45"), by: .watch)
        _ = await alarms.applyRemote(remote, at: DayFixture.at(1, "06:45"))
        #expect(await system.fixed.isEmpty)
    }

    @Test func anEarlyWakeForARingTheAlarmNoLongerHasChangesNothing() async {
        let alarms = library()
        await alarms.save(settings(Weekday.weekdays, hour: 7, minute: 30), id: id, now: DayFixture.at(0, "20:00"))
        #expect(!(await alarms.received(earlyWake, at: clock.now)))
        #expect(await system.repeating.values.first?.repeatDays == Weekday.weekdays)
    }

    @Test func aSkipThatCannotBeSavedLeavesTheBackstopToRing() async {
        let alarms = library(skips: URL(fileURLWithPath: "/dev/null/alarm-skips.json"))
        await alarms.save(settings(Weekday.weekdays), id: id, now: DayFixture.at(0, "20:00"))
        #expect(!(await alarms.received(earlyWake, at: clock.now)))
        #expect(await system.repeating.values.first?.repeatDays == Weekday.weekdays)
        #expect(await system.fixed.isEmpty)
    }
}
