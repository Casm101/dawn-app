import Foundation

/// When one habit falls on one waking day.
public struct HabitTime: Hashable, Sendable, Identifiable {
    private typealias T = Tuning.Habits

    public let habit: Habit
    public let start: Date
    /// The end, for a habit that lasts a while; nil for a moment.
    public let end: Date?
    /// The waking that starts the day this belongs to.
    public let wake: Date

    public var id: String { "\(habit.rawValue)-\(wake.timeIntervalSinceReferenceDate)" }

    /// When the habit is over: its end, or its moment.
    public var last: Date { end ?? start }

    /// The habits of several days, each day's from its waking until the next day's, so days that
    /// overlap, after a second long sleep, do not show a habit twice.
    public static func times(for days: [EnergySchedule]) -> [HabitTime] {
        times(forDays: days.map { DateInterval(start: $0.wake, end: $0.bedtime) })
    }

    /// The same, for days given as waking to bedtime.
    public static func times(forDays days: [DateInterval]) -> [HabitTime] {
        let days = days.sorted { $0.start < $1.start }.reduce(into: [DateInterval]()) { kept, day in
            if kept.last?.start != day.start { kept.append(day) }
        }
        return days.indices.flatMap { index in
            let next = days.indices.contains(index + 1) ? days[index + 1].start : .distantFuture
            return times(wake: days[index].start, bedtime: days[index].end).filter { $0.start >= days[index].start && $0.start < next }
        }
    }

    /// Every habit on the day `schedule` covers, in the order of `Habit.allCases`.
    public static func times(for schedule: EnergySchedule) -> [HabitTime] {
        times(wake: schedule.wake, bedtime: schedule.bedtime)
    }

    /// Every habit on a day from `wake` to `bedtime`, in the order of `Habit.allCases`.
    public static func times(wake: Date, bedtime: Date) -> [HabitTime] {
        let window = MelatoninAnchors(bedtime: bedtime).windowStart
        return Habit.allCases.map { habit in
            switch habit {
            case .morningLight:
                HabitTime(habit: habit, start: wake, end: wake.addingTimeInterval(T.morningLight), wake: wake)
            case .caffeineCutoff:
                HabitTime(habit: habit, start: window.addingTimeInterval(-T.caffeineBeforeWindow), end: nil, wake: wake)
            case .dimLights:
                HabitTime(habit: habit, start: bedtime.addingTimeInterval(-T.dimLightsBeforeBed), end: nil, wake: wake)
            case .windDown:
                HabitTime(habit: habit, start: bedtime.addingTimeInterval(-Tuning.Energy.windDownBeforeBed), end: nil, wake: wake)
            case .melatonin:
                HabitTime(habit: habit, start: bedtime.addingTimeInterval(-T.melatoninBeforeBed), end: nil, wake: wake)
            case .rateLastNight:
                HabitTime(habit: habit, start: wake.addingTimeInterval(T.rateAfterWake), end: nil, wake: wake)
            }
        }
    }
}
