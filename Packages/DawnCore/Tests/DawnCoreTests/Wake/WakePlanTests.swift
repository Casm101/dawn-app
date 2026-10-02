import Foundation
import Testing
@testable import DawnCore

/// Which window to arm (WakeTF's next-occurrence tests, MIT, across repeat days).
struct WakePlanTests {
    private typealias F = SleepFixture

    private func alarm(_ hour: Int, _ minute: Int, days: Set<Weekday> = Set(Weekday.allCases), window: Int = 30, on: Bool = true) -> AlarmDefinition {
        var document = AlarmDocument()
        let settings = AlarmSettings(isEnabled: on, time: ClockTime(hour: hour, minute: minute)!, repeatDays: days, windowMinutes: window)
        return document.save(settings, id: UUID(), at: F.at(0, "12:00"), by: .phone)
    }

    private func plan(_ alarms: [AlarmDefinition], now: Date, completed: Date? = nil) -> WakePlan? {
        WakePlan(alarms: alarms, now: now, completed: completed, calendar: F.calendar)
    }

    @Test func tonightsRingIsArmedWithItsWindowBeforeIt() {
        let result = plan([alarm(7, 0)], now: F.at(0, "22:00"))
        #expect(result?.windowStart == F.at(1, "06:30"))
        #expect(result?.windowEnd == F.at(1, "07:00"))
    }

    @Test func aWindowCanCrossMidnight() {
        let result = plan([alarm(0, 10, window: 20)], now: F.at(0, "21:00"))
        #expect(result?.windowStart == F.at(0, "23:50"))
        #expect(result?.windowEnd == F.at(1, "00:10"))
    }

    @Test func theEarliestEnabledRingWins() {
        let early = alarm(6, 0), late = alarm(8, 0), off = alarm(5, 0, on: false)
        #expect(plan([late, off, early], now: F.at(0, "22:00"))?.alarmID == early.id)
    }

    @Test func nothingWithinThirtySixHoursIsNothingToArm() {
        let saturday = alarm(7, 0, days: [.saturday])
        #expect(plan([saturday], now: F.at(0, "22:00")) == nil)
        #expect(plan([], now: F.at(0, "22:00")) == nil)
    }

    @Test func openingFromTheWakeAlertArmsTheFollowingNight() {
        let result = plan([alarm(7, 0)], now: F.at(1, "06:41"), completed: F.at(1, "07:00"))
        #expect(result?.windowEnd == F.at(2, "07:00"))
    }

    @Test func aWindowAlreadyUnderWayStartsNowAndAnAlmostOverOneIsNotArmed() {
        let result = plan([alarm(7, 0)], now: F.at(1, "06:45"))
        #expect(result?.start(at: F.at(1, "06:45")) == F.at(1, "06:45"))
        #expect(plan([alarm(7, 0)], now: F.at(1, "06:59").addingTimeInterval(30)) == nil)
    }

    @Test func theNudgeComesNineHoursBeforeTheRingOnlyWhileUnarmed() {
        let result = plan([alarm(7, 0)], now: F.at(0, "20:00"))
        #expect(BedtimeNudge.date(for: result, armedRing: nil, now: F.at(0, "20:00")) == F.at(0, "22:00"))
        #expect(BedtimeNudge.date(for: result, armedRing: F.at(1, "07:00"), now: F.at(0, "20:00")) == nil)
        #expect(BedtimeNudge.date(for: result, armedRing: nil, now: F.at(0, "23:00")) == nil)
        #expect(BedtimeNudge.isNeeded(for: result, armedRing: nil))
        #expect(!BedtimeNudge.isNeeded(for: nil, armedRing: nil))
    }

    @Test func aPlanIsCurrentOnlyWhileItsAlarmStillRingsThenWithTheSameWindow() throws {
        let daily = alarm(7, 0)
        let result = try #require(plan([daily], now: F.at(0, "22:00")))
        #expect(result.isCurrent(in: [daily], calendar: F.calendar))
        #expect(!result.isCurrent(in: [alarm(7, 30)], calendar: F.calendar))
        var moved = daily
        moved.wakeTime = Stamped(ClockTime(hour: 7, minute: 30)!, at: F.at(0, "23:00"), by: .watch)
        #expect(!result.isCurrent(in: [moved], calendar: F.calendar))
        var off = daily
        off.enabled = Stamped(false, at: F.at(0, "23:00"), by: .phone)
        #expect(!result.isCurrent(in: [off], calendar: F.calendar))
        var narrower = daily
        narrower.windowMinutes = Stamped(20, at: F.at(0, "23:00"), by: .watch)
        #expect(!result.isCurrent(in: [narrower], calendar: F.calendar))
        #expect(!result.isCurrent(in: [], calendar: F.calendar))
    }

    @Test func theWidgetIsRelevantFromTheNudgeOrNowUntilTheWindowWhileUnarmed() {
        let result = plan([alarm(7, 0)], now: F.at(0, "20:00"))
        let early = BedtimeNudge.relevance(for: result, armedRing: nil, now: F.at(0, "20:00"))
        #expect(early == DateInterval(start: F.at(0, "22:00"), end: F.at(1, "06:30")))
        let late = BedtimeNudge.relevance(for: result, armedRing: nil, now: F.at(0, "23:15"))
        #expect(late?.start == F.at(0, "23:15"))
        #expect(BedtimeNudge.relevance(for: result, armedRing: F.at(1, "07:00"), now: F.at(0, "23:15")) == nil)
    }

    @Test func onlyAnEarlyWakeBeforeTheRingStandsTheBackstopDown() {
        let outcome = WakeOutcome(alarmID: UUID(), windowStart: F.at(1, "06:30"), windowEnd: F.at(1, "07:00"), result: .wokeEarly)
        #expect(outcome.standsDownBackstop(at: F.at(1, "06:41")))
        #expect(!outcome.standsDownBackstop(at: F.at(1, "07:00")))
        var atEnd = outcome
        atEnd.result = .wokeAtEnd
        #expect(!atEnd.standsDownBackstop(at: F.at(1, "06:41")))
    }
}
