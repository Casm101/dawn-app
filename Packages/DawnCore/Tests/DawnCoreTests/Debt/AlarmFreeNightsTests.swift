import Foundation
import Testing
@testable import DawnCore

struct AlarmFreeNightsTests {
    private typealias D = DebtFixture

    /// An alarm switched on (or off) long before the fixture nights.
    private func alarm(
        _ hour: Int, _ minute: Int, days: Set<Weekday> = Set(Weekday.allCases), on: Bool = true,
        switchedAt: Date = SleepFixture.monday.addingTimeInterval(-30 * 86_400)
    ) -> AlarmDefinition {
        let settings = AlarmSettings(isEnabled: on, time: ClockTime(hour: hour, minute: minute)!, repeatDays: days)
        return AlarmDefinition(settings: settings, at: switchedAt, by: .phone)
    }

    private func free(_ nights: [SleepSession], _ alarms: [AlarmDefinition]) -> [TimeInterval] {
        AlarmFreeNights.asleep(in: nights, alarms: alarms, calendar: D.calendar)
    }

    @Test func aWakeNearAnAlarmIsNotFree() {
        #expect(free([D.night(0, hours: 7, wake: (7, 10))], [alarm(7, 0)]).isEmpty)
    }

    @Test func aWakeFarFromAnyAlarmIsFree() {
        #expect(free([D.night(0, hours: 9, wake: (9, 0))], [alarm(7, 0)]) == [9 * D.hour])
    }

    @Test func anAlarmForOtherDaysOrSwitchedOffLeavesTheNightFree() {
        let sunday = D.night(0, hours: 7, wake: (7, 0))
        #expect(free([sunday], [alarm(7, 0, days: Weekday.weekdays)]).count == 1)
        #expect(free([sunday], [alarm(7, 0, on: false)]).count == 1)
    }

    @Test func aOneOffAlarmSwitchedOffAfterItRangStillEndsItsNight() {
        let night = D.night(0, hours: 7, wake: (7, 5))
        let rang = alarm(7, 0, days: [], on: false, switchedAt: night.end.addingTimeInterval(600))
        #expect(free([night], [rang]).isEmpty)
    }

    @Test func anAlarmSwitchedOnAfterTheNightDidNotEndIt() {
        let night = D.night(0, hours: 7, wake: (7, 5))
        #expect(free([night], [alarm(7, 0, switchedAt: night.end.addingTimeInterval(600))]).count == 1)
    }

    @Test func napsAreNeverCounted() {
        #expect(free([D.nap(0, minutes: 40)], []).isEmpty)
    }

    @Test func freeNightsComeOldestFirst() {
        #expect(free([D.night(0, hours: 9), D.night(3, hours: 6)], []) == [6 * D.hour, 9 * D.hour])
    }
}
