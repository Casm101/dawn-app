import Foundation

/// A reminder for one habit on one day, as Dawn schedules it with the system.
public struct HabitReminder: Hashable, Sendable, Identifiable {
    /// The same for a habit on a given waking day, so a later plan can replace or cancel it.
    public let id: String
    public let habit: Habit
    public let date: Date

    public init(id: String, habit: Habit, date: Date) {
        self.id = id
        self.habit = habit
        self.date = date
    }
}
