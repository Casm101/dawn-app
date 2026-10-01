import Foundation

/// A reminder for one habit on one waking day, as Dawn schedules it with the system.
public struct HabitReminder: Hashable, Sendable, Codable, Identifiable {
    /// The same for a habit on a day that starts at a given waking, so a later plan can replace or cancel it.
    public let id: String
    public let habit: Habit
    /// The date of the waking that starts the reminder's day.
    public let day: CalendarDay
    public let date: Date

    public init(id: String, habit: Habit, day: CalendarDay, date: Date) {
        self.id = id
        self.habit = habit
        self.day = day
        self.date = date
    }

    /// Which habit on which waking date, the unit a reminder fires at most once for.
    public var habitDay: HabitDay { HabitDay(habit: habit, day: day) }
}
