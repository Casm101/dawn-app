import Foundation
import Testing
@testable import DawnCore

/// Which reminders should be pending.
struct HabitReminderPlanTests {
    private typealias F = SleepFixture

    private func days(now: Date, wake: String = "07:00") -> [DateInterval] {
        let sessions = EnergyFixture.nights(7, endingMorning: 7, wake: wake)
        let schedules = EnergyForecast(sessions: sessions, usual: EnergyFixture.usual, now: now, calendar: F.calendar).days
        let habitual = HabitualSleep(sessions: sessions, usual: EnergyFixture.usual, now: now, calendar: F.calendar)
        return HabitReminderPlan.days(from: schedules, habitual: habitual, now: now, calendar: F.calendar)
    }

    private func reminding(_ habits: Habit...) -> HabitSettings {
        HabitSettings(shown: Set(Habit.allCases), reminded: Set(habits))
    }

    private func plan(_ days: [DateInterval], _ settings: HabitSettings, now: Date, log: HabitReminderLog = HabitReminderLog()) -> [HabitReminder] {
        HabitReminderPlan.reminders(days: days, settings: settings, now: now, calendar: F.calendar, log: log)
    }

    @Test func onlyRemindedHabitsStillToComeArePlanned() {
        let planned = plan(days(now: F.at(7, "10:00")), reminding(.windDown, .rateLastNight), now: F.at(7, "10:00"))
        #expect(planned.prefix(3).map(\.id) == [
            "dawn.habit.windDown.2026-10-05-0700", "dawn.habit.rateLastNight.2026-10-06-0700", "dawn.habit.windDown.2026-10-06-0700",
        ])
        #expect(planned.first?.date == F.at(7, "21:30"))
    }

    @Test func remindersReachAWeekAheadAndStayUnderTheSystemLimit() {
        let planned = plan(days(now: F.at(7, "10:00")), HabitSettings(shown: Set(Habit.allCases), reminded: Set(Habit.allCases)), now: F.at(7, "10:00"))
        #expect(planned.contains { $0.habit == .windDown && $0.date == F.at(14, "21:30") })
        #expect(planned.count <= 64)
    }

    @Test func nothingIsPlannedWhileTheUserIsAsleep() {
        // A day whose bedtime comes before its rating prompt: the prompt falls in the night after it.
        let short = DateInterval(start: F.at(0, "07:00"), end: F.at(0, "08:00"))
        let next = DateInterval(start: F.at(1, "07:00"), end: F.at(1, "23:00"))
        let planned = plan([short, next], reminding(.rateLastNight, .morningLight), now: F.at(0, "06:00"))
        #expect(HabitReminderPlan.sleepWindows([short, next]) == [DateInterval(start: F.at(0, "08:00"), end: F.at(1, "07:00"))])
        #expect(planned.map(\.date) == [F.at(0, "07:00"), F.at(1, "07:00"), F.at(1, "08:30")])
    }

    @Test func aReminderThatWentOffIsNotPlannedAgainWhenTheWakeMoves() {
        let usual = reminding(.rateLastNight)
        var log = HabitReminderLog()
        log.plan(plan(days(now: F.at(6, "22:00")), usual, now: F.at(6, "22:00")))
        log.advance(to: F.at(7, "08:31"), calendar: F.calendar)
        let after = plan(days(now: F.at(7, "08:31"), wake: "07:40"), usual, now: F.at(7, "08:31"), log: log)
        #expect(!after.contains { $0.day == CalendarDay(F.at(7, "00:00"), calendar: F.calendar) })
        #expect(after.first?.date == F.at(8, "09:10"))
    }

    @Test func aRatedNightGetsNoRatingPrompt() {
        let planned = HabitReminderPlan.reminders(
            days: days(now: F.at(7, "06:00")), settings: reminding(.rateLastNight), now: F.at(7, "06:00"), calendar: F.calendar,
            isRated: { $0 == F.at(7, "07:00") }
        )
        #expect(planned.first?.date == F.at(8, "08:30"))
    }

    @Test func aSecondLongSleepStartsADayWhoseHabitsTakeOver() {
        let habitual = HabitualSleep(sessions: [], usual: UsualSleep(bedtime: ClockTime(hour: 0, minute: 0)!, wakeTime: ClockTime(hour: 7, minute: 0)!), now: F.at(0, "06:00"), calendar: F.calendar)
        let morning = EnergySchedule(wake: F.at(0, "07:00"), habitual: habitual, sessions: [], calendar: F.calendar)
        let evening = EnergySchedule(wake: F.at(0, "19:48"), habitual: habitual, sessions: [], calendar: F.calendar)
        let times = HabitTime.times(for: [evening, morning])
        #expect(times.filter { $0.habit == .dimLights }.map(\.wake) == [F.at(0, "19:48")])
        #expect(times.filter { $0.habit == .rateLastNight }.map(\.start) == [F.at(0, "08:30"), F.at(0, "21:18")])
        let planned = plan([morning, evening].map { DateInterval(start: $0.wake, end: $0.bedtime) }, reminding(.rateLastNight), now: F.at(0, "06:00"))
        #expect(Set(planned.map(\.id)).count == 2)
    }
}
