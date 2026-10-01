import Foundation
import Testing
@testable import DawnCore

/// Pending reminders brought in line with the plan.
struct HabitReminderSyncTests {
    private typealias F = SleepFixture

    private func reminder(_ habit: Habit, _ time: String) -> HabitReminder {
        HabitReminder(id: "dawn.habit.\(habit.rawValue).2026-09-28", habit: habit, date: F.at(0, time))
    }

    @Test func onlyWhatDiffersIsAddedOrRemoved() async {
        let center = FakeReminderCenter(pending: [reminder(.windDown, "21:30"), reminder(.dimLights, "21:00"), reminder(.melatonin, "16:30")])
        await HabitReminderSync.apply([reminder(.windDown, "21:30"), reminder(.dimLights, "21:10"), reminder(.caffeineCutoff, "12:03")], to: center)
        #expect(await center.removed == ["dawn.habit.melatonin.2026-09-28"])
        #expect(await center.added == [reminder(.dimLights, "21:10"), reminder(.caffeineCutoff, "12:03")])
    }

    @Test func turningAHabitOffCancelsItsPendingReminder() async {
        var settings = HabitSettings(shown: Set(Habit.allCases), reminded: [.windDown, .dimLights])
        let days = EnergyForecast(sessions: EnergyFixture.nights(7, endingMorning: 7), usual: EnergyFixture.usual, now: F.at(7, "10:00"), calendar: F.calendar).days
        let center = FakeReminderCenter()
        await HabitReminderSync.apply(HabitReminderPlan.reminders(days: days, settings: settings, now: F.at(7, "10:00"), calendar: F.calendar), to: center)
        settings.show(.windDown, false)
        await HabitReminderSync.apply(HabitReminderPlan.reminders(days: days, settings: settings, now: F.at(7, "10:00"), calendar: F.calendar), to: center)
        #expect(await center.reminders.allSatisfy { $0.habit == .dimLights })
        #expect(await center.removed.allSatisfy { $0.contains("windDown") })
    }
}
