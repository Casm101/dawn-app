import Foundation
import Testing
@testable import DawnCore

/// The rings to come, for reminders a week ahead, and one-off alarms that have already rung.
struct WakePlanUpcomingTests {
    private typealias F = SleepFixture

    private func alarm(days: Set<Weekday>, setAt: Date) -> AlarmDefinition {
        AlarmDefinition(settings: AlarmSettings(time: ClockTime(hour: 7, minute: 0)!, repeatDays: days), at: setAt, by: .watch)
    }

    @Test func afterFridaysRingTheWeekAheadStillHasItsRingsButNothingToArm() {
        // Day 4 is Friday 2 October 2026.
        let weekdays = [alarm(days: Weekday.weekdays, setAt: F.at(0, "00:00"))]
        let coming = WakePlan.upcoming(alarms: weekdays, now: F.at(4, "08:00"), within: Tuning.Wake.nudgeHorizon, calendar: F.calendar)
        #expect(coming.map(\.windowEnd) == (7...11).map { F.at($0, "07:00") })
        #expect(WakePlan(alarms: weekdays, now: F.at(4, "08:00"), calendar: F.calendar) == nil)
    }

    @Test func aOneOffThatHasRungPlansNothingMore() {
        let once = [alarm(days: [], setAt: F.at(0, "20:00"))]
        #expect(WakePlan(alarms: once, now: F.at(1, "06:00"), calendar: F.calendar)?.windowEnd == F.at(1, "07:00"))
        #expect(WakePlan(alarms: once, now: F.at(1, "08:00"), calendar: F.calendar) == nil)
        #expect(WakePlan.upcoming(alarms: once, now: F.at(1, "08:00"), within: Tuning.Wake.nudgeHorizon, calendar: F.calendar).isEmpty)
    }

    @Test func aOneOffSetEarlierTheSameMorningKeepsThatMorningsRing() {
        let once = [alarm(days: [], setAt: F.at(0, "05:00"))]
        #expect(WakePlan(alarms: once, now: F.at(0, "06:00"), calendar: F.calendar)?.windowEnd == F.at(0, "07:00"))
    }
}
