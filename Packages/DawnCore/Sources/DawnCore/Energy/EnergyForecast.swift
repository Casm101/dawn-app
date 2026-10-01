import Foundation

/// The day's energy schedule as of a moment, and the one Dawn gave a day earlier to compare with.
public struct EnergyForecast: Hashable, Sendable {
    public let today: EnergySchedule
    public let yesterday: EnergySchedule

    public init(sessions: [SleepSession], usual: UsualSleep, now: Date, calendar: Calendar) {
        let dayBefore = calendar.date(byAdding: .day, value: -1, to: now) ?? now.addingTimeInterval(-24 * 3600)
        today = Self.schedule(Self.anchor(sessions: sessions, usual: usual, now: now, calendar: calendar), sessions, calendar)
        yesterday = Self.schedule(Self.anchor(sessions: sessions, usual: usual, now: dayBefore, calendar: calendar), sessions, calendar)
    }

    /// The waking a day's schedule starts from, and the habitual times it uses. Cheap: no curve.
    public struct Anchor: Hashable, Sendable {
        public let wake: Date
        public let habitual: HabitualSleep
    }

    /// From the latest waking at or before now: last night's end when it is recent and the nights
    /// are enough to go on, otherwise the habitual wake time. Once that day's melatonin window is
    /// over, the next day, from the next habitual wake time.
    public static func anchor(sessions: [SleepSession], usual: UsualSleep, now: Date, calendar: Calendar) -> Anchor {
        let habitual = HabitualSleep(sessions: sessions, usual: usual, now: now, calendar: calendar)
        let recentNight = sessions.filter { night in
            night.kind == .night && night.end <= now && now.timeIntervalSince(night.end) <= Tuning.Energy.lastWakeValidity
        }.max { $0.end < $1.end }
        var wake = habitual.isLearning ? nil : recentNight?.end
        if wake == nil {
            let todays = habitual.wakeTime.date(on: now, calendar: calendar)
            wake = todays <= now ? todays : calendar.date(byAdding: .day, value: -1, to: todays)
        }
        let latest = wake ?? now
        let bedtime = EnergySchedule.bedtime(after: latest, habitual: habitual, calendar: calendar)
        guard now >= MelatoninAnchors(bedtime: bedtime).windowEnd else { return Anchor(wake: latest, habitual: habitual) }
        var next = habitual.wakeTime.date(on: now, calendar: calendar)
        if next <= now { next = calendar.date(byAdding: .day, value: 1, to: next) ?? next }
        return Anchor(wake: next, habitual: habitual)
    }

    private static func schedule(_ anchor: Anchor, _ sessions: [SleepSession], _ calendar: Calendar) -> EnergySchedule {
        EnergySchedule(wake: anchor.wake, habitual: anchor.habitual, sessions: sessions, calendar: calendar)
    }
}
