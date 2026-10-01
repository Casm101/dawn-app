import Foundation
import Testing
@testable import DawnCore

/// Which reminders should be pending.
struct HabitReminderPlanTests {
    private typealias F = SleepFixture

    private func days(now: Date, wake: String = "07:00") -> [EnergySchedule] {
        let sessions = EnergyFixture.nights(7, endingMorning: 7, wake: wake)
        return EnergyForecast(sessions: sessions, usual: EnergyFixture.usual, now: now, calendar: F.calendar).days
    }

    private func reminding(_ habits: Habit...) -> HabitSettings {
        HabitSettings(shown: Set(Habit.allCases), reminded: Set(habits))
    }

    @Test func onlyRemindedHabitsStillToComeArePlanned() {
        let plan = HabitReminderPlan.reminders(days: days(now: F.at(7, "10:00")), settings: reminding(.windDown, .rateLastNight), now: F.at(7, "10:00"), calendar: F.calendar)
        #expect(plan.map(\.id) == [
            "dawn.habit.windDown.2026-10-05-0700", "dawn.habit.rateLastNight.2026-10-06-0700", "dawn.habit.windDown.2026-10-06-0700",
        ])
        #expect(plan.first?.date == F.at(7, "21:30"))
    }

    @Test func nothingIsPlannedWhileTheUserIsAsleep() {
        let habitual = HabitualSleep(sessions: [], usual: UsualSleep(bedtime: ClockTime(hour: 23, minute: 0)!, wakeTime: ClockTime(hour: 7, minute: 0)!), now: F.at(0, "06:00"), calendar: F.calendar)
        let early = EnergySchedule(wake: F.at(0, "07:00"), habitual: habitual, sessions: [], calendar: F.calendar)
        let late = EnergySchedule(wake: F.at(1, "13:00"), habitual: habitual, sessions: [], calendar: F.calendar)
        let plan = HabitReminderPlan.reminders(days: [early, late], settings: reminding(Habit.allCases), now: F.at(0, "06:00"), calendar: F.calendar)
        let asleep = DateInterval(start: F.at(0, "23:00"), end: F.at(1, "13:00"))
        #expect(HabitReminderPlan.sleepWindows([early, late]) == [asleep])
        #expect(!plan.contains { asleep.start <= $0.date && $0.date < asleep.end })
        #expect(!plan.contains { $0.habit == .caffeineCutoff && $0.date == F.at(1, "12:03") })
        #expect(plan.contains { $0.id == "dawn.habit.dimLights.2026-09-29-1300" })
    }

    @Test func aLaterWakeReplacesTheReminder() async {
        let usual = reminding(.rateLastNight)
        let before = HabitReminderPlan.reminders(days: days(now: F.at(7, "06:00")), settings: usual, now: F.at(7, "06:00"), calendar: F.calendar)
        let after = HabitReminderPlan.reminders(days: days(now: F.at(7, "09:00"), wake: "08:00"), settings: usual, now: F.at(7, "09:00"), calendar: F.calendar)
        #expect(before.first?.date == F.at(7, "08:30"))
        #expect(after.first?.date == F.at(7, "09:30"))
        let center = FakeReminderCenter()
        await HabitReminderSync.apply(before, to: center)
        await HabitReminderSync.apply(after, to: center)
        #expect(await center.reminders.filter { $0.date < F.at(8, "00:00") }.map(\.date) == [F.at(7, "09:30")])
    }

    @Test func aSecondLongSleepStartsADayWhoseHabitsTakeOver() {
        let habitual = HabitualSleep(sessions: [], usual: UsualSleep(bedtime: ClockTime(hour: 0, minute: 0)!, wakeTime: ClockTime(hour: 7, minute: 0)!), now: F.at(0, "06:00"), calendar: F.calendar)
        let morning = EnergySchedule(wake: F.at(0, "07:00"), habitual: habitual, sessions: [], calendar: F.calendar)
        let evening = EnergySchedule(wake: F.at(0, "19:48"), habitual: habitual, sessions: [], calendar: F.calendar)
        let times = HabitTime.times(for: [evening, morning])
        #expect(times.filter { $0.habit == .dimLights }.map(\.wake) == [F.at(0, "19:48")])
        #expect(times.filter { $0.habit == .rateLastNight }.map(\.start) == [F.at(0, "08:30"), F.at(0, "21:18")])
        let plan = HabitReminderPlan.reminders(days: [morning, evening], settings: reminding(.rateLastNight), now: F.at(0, "06:00"), calendar: F.calendar)
        #expect(Set(plan.map(\.id)).count == 2)
    }

    private func reminding(_ habits: [Habit]) -> HabitSettings {
        HabitSettings(shown: Set(Habit.allCases), reminded: Set(habits))
    }
}
