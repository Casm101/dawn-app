import Foundation
import Testing
@testable import DawnCore

/// What has already gone off.
struct HabitReminderLogTests {
    private typealias F = SleepFixture

    private func reminder(_ habit: Habit, day: Int, _ time: String) -> HabitReminder {
        HabitReminder(id: "\(habit.rawValue)-\(day)", habit: habit, day: CalendarDay(F.at(day, "00:00"), calendar: F.calendar), date: F.at(day, time))
    }

    @Test func aPlannedReminderWhoseTimeHasComeHasFired() {
        var log = HabitReminderLog()
        log.plan([reminder(.dimLights, day: 0, "21:00"), reminder(.windDown, day: 0, "21:30")])
        log.advance(to: F.at(0, "21:10"), calendar: F.calendar)
        #expect(log.hasFired(.dimLights, on: CalendarDay(F.at(0, "00:00"), calendar: F.calendar)))
        #expect(!log.hasFired(.windDown, on: CalendarDay(F.at(0, "00:00"), calendar: F.calendar)))
        #expect(log.planned.map(\.habit) == [.windDown])
    }

    @Test func oldDaysAreForgotten() {
        var log = HabitReminderLog()
        log.plan([reminder(.dimLights, day: 0, "21:00")])
        log.advance(to: F.at(0, "22:00"), calendar: F.calendar)
        log.advance(to: F.at(2, "09:00"), calendar: F.calendar)
        #expect(log.fired.count == 1)
        log.advance(to: F.at(3, "09:00"), calendar: F.calendar)
        #expect(log.fired.isEmpty)
    }

    @Test func updatingGivesAPlanOnlyWhenItChangesOrIsForced() {
        let days = [DateInterval(start: F.at(0, "07:00"), end: F.at(0, "23:00"))]
        let settings = HabitSettings(shown: Set(Habit.allCases), reminded: [.windDown])
        var log = HabitReminderLog()
        #expect(log.update(days: days, settings: settings, now: F.at(0, "10:00"), calendar: F.calendar)?.map(\.habit) == [.windDown])
        #expect(log.update(days: days, settings: settings, now: F.at(0, "11:00"), calendar: F.calendar) == nil)
        #expect(log.update(days: days, settings: settings, now: F.at(0, "11:00"), calendar: F.calendar, force: true) != nil)
        // Once it has gone off there is nothing left to change, and it counts as fired.
        #expect(log.update(days: days, settings: settings, now: F.at(0, "21:31"), calendar: F.calendar) == nil)
        #expect(log.hasFired(.windDown, on: CalendarDay(F.at(0, "00:00"), calendar: F.calendar)))
    }

    @Test func theLogSurvivesBeingSavedAndReadBack() throws {
        var log = HabitReminderLog()
        log.plan([reminder(.dimLights, day: 0, "21:00"), reminder(.windDown, day: 0, "21:30")])
        log.advance(to: F.at(0, "21:10"), calendar: F.calendar)
        let file = JSONFile<HabitReminderLog>(url: FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID()).json"))
        try file.write(log)
        #expect(try file.read() == log)
    }
}
