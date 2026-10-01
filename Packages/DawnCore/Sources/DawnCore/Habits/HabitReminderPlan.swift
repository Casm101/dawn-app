import Foundation

/// The reminders that should be pending: the reminded habits still to come over the next
/// `Tuning.Habits.planDays`, except any that fall while the user is asleep, any that already went
/// off that day, and the rating prompt for a night already rated.
public enum HabitReminderPlan {
    /// The waking days to plan over, each from waking to bedtime: the forecast's days, then the
    /// usual days after them until `Tuning.Habits.planDays` past now.
    public static func days(from schedules: [EnergySchedule], habitual: HabitualSleep, now: Date, calendar: Calendar) -> [DateInterval] {
        let sorted = schedules.sorted { $0.wake < $1.wake }
        var days = sorted.map { DateInterval(start: $0.wake, end: $0.bedtime) }
        guard let latest = sorted.last else { return days }
        let horizon = calendar.date(byAdding: .day, value: Tuning.Habits.planDays, to: now) ?? now
        var anchor = EnergyAnchor(wake: latest.wake, habitual: habitual)
        while anchor.wake < horizon {
            let next = EnergyAnchors.after(anchor, calendar: calendar)
            guard next.wake > anchor.wake else { break }
            days.append(DateInterval(start: next.wake, end: EnergySchedule.bedtime(after: next.wake, habitual: habitual, calendar: calendar)))
            anchor = next
        }
        return days
    }

    public static func reminders(
        days: [DateInterval], settings: HabitSettings, now: Date, calendar: Calendar,
        log: HabitReminderLog = HabitReminderLog(), isRated: (Date) -> Bool = { _ in false }
    ) -> [HabitReminder] {
        let asleep = sleepWindows(days.sorted { $0.start < $1.start })
        return HabitTime.times(forDays: days).compactMap { time in
            let day = CalendarDay(time.wake, calendar: calendar)
            guard settings.reminds(time.habit), time.start > now, !log.hasFired(time.habit, on: day),
                  !(time.habit == .rateLastNight && isRated(time.wake)),
                  !asleep.contains(where: { $0.start <= time.start && time.start < $0.end }) else { return nil }
            // Whole seconds, as the system hands pending times back, so an unchanged reminder compares equal.
            let date = Date(timeIntervalSinceReferenceDate: time.start.timeIntervalSinceReferenceDate.rounded(.down))
            return HabitReminder(id: id(time.habit, wake: time.wake, calendar: calendar), habit: time.habit, day: day, date: date)
        }
        .sorted { $0.date < $1.date }
    }

    /// From each day's bedtime to the next day's waking.
    public static func sleepWindows(_ days: [DateInterval]) -> [DateInterval] {
        zip(days, days.dropFirst()).compactMap { day, next in
            day.end < next.start ? DateInterval(start: day.end, end: next.start) : nil
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
