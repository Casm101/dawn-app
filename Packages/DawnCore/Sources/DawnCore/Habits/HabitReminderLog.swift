import Foundation

/// What Dawn last asked the system to remind about, and which habits have already had their
/// reminder on each recent waking date. A habit fires at most once a day, even when a later wake or
/// bedtime moves its time after it went off.
public struct HabitReminderLog: Hashable, Sendable, Codable {
    public private(set) var planned: [HabitReminder] = []
    public private(set) var fired: Set<HabitDay> = []

    public init(planned: [HabitReminder] = [], fired: Set<HabitDay> = []) {
        self.planned = planned
        self.fired = fired
    }

    public func hasFired(_ habit: Habit, on day: CalendarDay) -> Bool {
        fired.contains(HabitDay(habit: habit, day: day))
    }

    /// Counts every planned reminder whose time has come as fired, and forgets days long gone.
    public mutating func advance(to now: Date, calendar: Calendar) {
        fired.formUnion(planned.filter { $0.date <= now }.map(\.habitDay))
        planned.removeAll { $0.date <= now }
        let today = calendar.startOfDay(for: now)
        let oldest = calendar.date(byAdding: .day, value: -Tuning.Habits.firedMemoryDays, to: today) ?? today
        fired = fired.filter { ($0.day.start(in: calendar) ?? .distantPast) >= oldest }
    }

    public mutating func plan(_ reminders: [HabitReminder]) {
        planned = reminders
    }
}
