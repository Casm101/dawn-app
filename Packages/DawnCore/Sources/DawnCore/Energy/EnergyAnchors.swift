import Foundation

/// The wakings a forecast is built from. Cheap, with no curve, so the cache can compare them.
public struct EnergyAnchors: Hashable, Sendable {
    /// The day before the latest waking, the latest waking's day, and the next day after it.
    public let previous: EnergyAnchor
    public let current: EnergyAnchor
    public let next: EnergyAnchor
    /// The day Home shows: the latest waking's day until its melatonin window ends, then the next.
    public let today: EnergyAnchor
    /// The day Home showed a day earlier, for the change since yesterday.
    public let yesterday: EnergyAnchor

    public init(sessions: [SleepSession], usual: UsualSleep, now: Date, calendar: Calendar) {
        current = Self.latest(sessions: sessions, usual: usual, now: now, calendar: calendar)
        previous = Self.latest(
            sessions: sessions, usual: usual, now: current.wake.addingTimeInterval(-Tuning.Energy.shortestDay), calendar: calendar
        )
        next = Self.after(current, calendar: calendar)
        today = Self.shown(current, next: next, now: now, calendar: calendar)
        let dayBefore = calendar.date(byAdding: .day, value: -1, to: now) ?? now.addingTimeInterval(-24 * 3600)
        let then = Self.latest(sessions: sessions, usual: usual, now: dayBefore, calendar: calendar)
        yesterday = Self.shown(then, next: Self.after(then, calendar: calendar), now: dayBefore, calendar: calendar)
    }

    /// The latest waking at or before now: last night's end when it is recent, long enough and the
    /// nights are enough to go on, otherwise the habitual wake time.
    static func latest(sessions: [SleepSession], usual: UsualSleep, now: Date, calendar: Calendar) -> EnergyAnchor {
        let habitual = HabitualSleep(sessions: sessions, usual: usual, now: now, calendar: calendar)
        let recentNight = sessions.filter { night in
            night.kind == .night && night.span >= Tuning.Energy.mainSleep && night.end <= now
                && now.timeIntervalSince(night.end) <= Tuning.Energy.lastWakeValidity
        }.max { $0.end < $1.end }
        if !habitual.isLearning, let night = recentNight { return EnergyAnchor(wake: night.end, habitual: habitual) }
        let todays = habitual.wakeTime.date(on: now, calendar: calendar)
        let wake = todays <= now ? todays : (calendar.date(byAdding: .day, value: -1, to: todays) ?? todays)
        return EnergyAnchor(wake: wake, habitual: habitual)
    }

    /// The next habitual waking after the day's melatonin window has ended.
    static func after(_ day: EnergyAnchor, calendar: Calendar) -> EnergyAnchor {
        let end = MelatoninAnchors(bedtime: EnergySchedule.bedtime(after: day.wake, habitual: day.habitual, calendar: calendar)).windowEnd
        var wake = day.habitual.wakeTime.date(on: end, calendar: calendar)
        while wake <= end { wake = calendar.date(byAdding: .day, value: 1, to: wake) ?? end.addingTimeInterval(1) }
        return EnergyAnchor(wake: wake, habitual: day.habitual)
    }

    private static func shown(_ day: EnergyAnchor, next: EnergyAnchor, now: Date, calendar: Calendar) -> EnergyAnchor {
        let end = MelatoninAnchors(bedtime: EnergySchedule.bedtime(after: day.wake, habitual: day.habitual, calendar: calendar)).windowEnd
        return now < end ? day : next
    }
}
