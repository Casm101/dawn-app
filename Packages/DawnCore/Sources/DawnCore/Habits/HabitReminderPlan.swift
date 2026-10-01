import Foundation

/// The reminders that should be pending: the reminded habits still to come on the forecast's days,
/// except any that fall while the user is asleep.
public enum HabitReminderPlan {
    public static func reminders(days: [EnergySchedule], settings: HabitSettings, now: Date, calendar: Calendar) -> [HabitReminder] {
        let asleep = sleepWindows(days.sorted { $0.wake < $1.wake })
        return HabitTime.times(for: days).compactMap { time in
            guard settings.reminds(time.habit), time.start > now,
                  !asleep.contains(where: { $0.start <= time.start && time.start < $0.end }) else { return nil }
            return HabitReminder(id: id(time.habit, wake: time.wake, calendar: calendar), habit: time.habit, date: time.start)
        }
        .sorted { $0.date < $1.date }
    }

    /// From each day's bedtime to the next day's waking.
    public static func sleepWindows(_ days: [EnergySchedule]) -> [DateInterval] {
        zip(days, days.dropFirst()).compactMap { day, next in
            day.bedtime < next.wake ? DateInterval(start: day.bedtime, end: next.wake) : nil
        }
    }

    /// The identifier for a habit on the day that starts at `wake`, such as
    /// "dawn.habit.windDown.2026-10-01-0700". A day that starts at another time gets another one.
    public static func id(_ habit: Habit, wake: Date, calendar: Calendar) -> String {
        let parts = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: wake)
        let stamp = String(
            format: "%04d-%02d-%02d-%02d%02d", parts.year ?? 0, parts.month ?? 0, parts.day ?? 0, parts.hour ?? 0, parts.minute ?? 0
        )
        return Tuning.Habits.reminderPrefix + habit.rawValue + "." + stamp
    }
}
