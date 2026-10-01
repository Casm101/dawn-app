/// The system's pending reminders, as far as Dawn's own go. UserNotifications sits behind it in the
/// app; tests use a fake.
public protocol HabitReminderCenter: Sendable {
    /// Only the reminders Dawn scheduled, with identifiers starting with `Tuning.Habits.reminderPrefix`.
    func pending() async -> [HabitReminder]
    /// Schedules a reminder, replacing any pending one with the same identifier.
    func add(_ reminder: HabitReminder) async
    func remove(_ ids: [String]) async
}
