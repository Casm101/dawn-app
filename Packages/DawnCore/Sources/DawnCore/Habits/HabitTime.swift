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
        let days = days.sorted { $0.wake < $1.wake }.reduce(into: [EnergySchedule]()) { kept, day in
            if kept.last?.wake != day.wake { kept.append(day) }
        }
        return days.indices.flatMap { index in
            let next = days.indices.contains(index + 1) ? days[index + 1].wake : .distantFuture
            return times(for: days[index]).filter { $0.start >= days[index].wake && $0.start < next }
        }
    }

    /// Every habit on the day `schedule` covers, in the order of `Habit.allCases`.
    public static func times(for schedule: EnergySchedule) -> [HabitTime] {
        let wake = schedule.wake, bedtime = schedule.bedtime
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
                HabitTime(habit: habit, start: bedtime.addingTimeInterval(-T.windDownBeforeBed), end: nil, wake: wake)
            case .melatonin:
                HabitTime(habit: habit, start: bedtime.addingTimeInterval(-T.melatoninBeforeBed), end: nil, wake: wake)
            case .rateLastNight:
                HabitTime(habit: habit, start: wake.addingTimeInterval(T.rateAfterWake), end: nil, wake: wake)
            }
        }
    }
}
