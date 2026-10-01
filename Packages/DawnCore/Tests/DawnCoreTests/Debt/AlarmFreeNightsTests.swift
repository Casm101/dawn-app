import Foundation
import Testing
@testable import DawnCore

struct AlarmFreeNightsTests {
    private typealias D = DebtFixture

    private func alarm(_ hour: Int, _ minute: Int, days: Set<Weekday> = Weekday.allCases.reduce(into: []) { $0.insert($1) }, on: Bool = true) -> AlarmSettings {
        AlarmSettings(isEnabled: on, time: ClockTime(hour: hour, minute: minute)!, repeatDays: days)
    }

    private func free(_ nights: [SleepSession], _ alarms: [AlarmSettings]) -> [TimeInterval] {
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

    @Test func napsAreNeverCounted() {
        #expect(free([D.nap(0, minutes: 40)], []).isEmpty)
    }

    @Test func freeNightsComeOldestFirst() {
        #expect(free([D.night(0, hours: 9), D.night(3, hours: 6)], []) == [6 * D.hour, 9 * D.hour])
    }
}
