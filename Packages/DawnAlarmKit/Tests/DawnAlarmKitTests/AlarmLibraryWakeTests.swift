import DawnCore
import Foundation
import Testing
@testable import DawnAlarmKit

/// The phone's backstop when the Watch wakes the wearer first.
@MainActor
struct AlarmLibraryWakeTests {
    private let url = FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID().uuidString).json")
    private let system = FakeAlarmScheduler()
    private let clock = TestClock(DayFixture.at(1, "06:41"))
    private let id = UUID()

    private func library() -> AlarmLibrary {
        AlarmLibrary(
            file: JSONFile(url: url),
            sync: AlarmSystemSync(scheduler: system, clock: { [clock] in clock.now }, calendar: DayFixture.calendar),
            authorizer: FakeAlarmAuthorizer(current: .authorized), calendar: DayFixture.calendar
        )
    }

    private func settings(_ days: Set<Weekday>) -> AlarmSettings {
        AlarmSettings(time: ClockTime(hour: 7, minute: 0)!, repeatDays: days)
    }

    /// The fixture's day 1 is Tuesday 29 September 2026.
    private func earlyWake(ring: Date = DayFixture.at(1, "07:00")) -> WakeOutcome {
        WakeOutcome(alarmID: id, windowStart: ring.addingTimeInterval(-1800), windowEnd: ring, result: .wokeEarly, trigger: .stirring)
    }

    @Test func anEarlyWakeLeavesOutThatWeekdayAndKeepsTheRestAndNextWeek() async {
        let alarms = library()
        await alarms.save(settings(Weekday.weekdays), id: id, now: DayFixture.at(0, "20:00"))
        #expect(await alarms.received(earlyWake(), at: clock.now))
        #expect(await system.repeating.values.first?.repeatDays == Weekday.weekdays.subtracting([.tuesday]))
        #expect(await system.fixed.values.first?.date == DayFixture.at(8, "07:00"))
    }

    @Test func afterTheRingTheFullAlarmComesBackAndNextWeeksStandInGoes() async {
        let alarms = library()
        await alarms.save(settings(Weekday.weekdays), id: id, now: DayFixture.at(0, "20:00"))
        await alarms.received(earlyWake(), at: clock.now)
        clock.now = DayFixture.at(1, "09:00")
        await alarms.load(now: clock.now)
        #expect(await system.repeating.values.first?.repeatDays == Weekday.weekdays)
        #expect(await system.fixed.isEmpty)
        #expect(alarms.alarms.first?.settings.isEnabled == true)
    }

    @Test func aOneOffStoodDownRingsNowhereAndIsOffOnceItsTimeHasPassed() async throws {
        let alarms = library()
        await alarms.save(settings([]), id: id, now: DayFixture.at(0, "20:00"))
        await alarms.received(earlyWake(), at: clock.now)
        #expect(try await system.userAlarmIDs().isEmpty)
        #expect(await system.fixed.isEmpty)
        clock.now = DayFixture.at(1, "09:00")
        await alarms.load(now: clock.now)
        #expect(alarms.alarms.first?.settings.isEnabled == false)
    }

    @Test func aCheckBeforeTheRingDoesNotSwitchOffAnAlarmWhoseOnlyDayIsStoodDown() async {
        let alarms = library()
        await alarms.save(settings([.tuesday]), id: id, now: DayFixture.at(0, "20:00"))
        await alarms.received(earlyWake(), at: clock.now)
        await alarms.load(now: clock.now)
        #expect(alarms.alarms.first?.settings.isEnabled == true)
        #expect(await system.fixed.count == 1)
    }

    @Test func anEarlyWakeArrivingAfterTheRingChangesNothing() async throws {
        let alarms = library()
        await alarms.save(settings(Weekday.weekdays), id: id, now: DayFixture.at(0, "20:00"))
        clock.now = DayFixture.at(1, "07:05")
        #expect(!(await alarms.received(earlyWake(), at: clock.now)))
        #expect(await system.repeating.values.first?.repeatDays == Weekday.weekdays)
        #expect(await system.fixed.isEmpty)
    }

    @Test func anEditWhileStoodDownKeepsTheSkipAndSwitchingOffDropsNextWeeksStandIn() async {
        let alarms = library()
        await alarms.save(settings(Weekday.weekdays), id: id, now: DayFixture.at(0, "20:00"))
        await alarms.received(earlyWake(), at: clock.now)
        var louder = settings(Weekday.weekdays)
        louder.sound = .pulse
        await alarms.save(louder, id: id, now: clock.now)
        #expect(await system.repeating.values.first?.repeatDays.contains(.tuesday) == false)
        await alarms.setEnabled(false, for: id, now: clock.now)
        #expect(await system.fixed.isEmpty)
    }
}
