import Foundation

/// What a chosen alarm time means for the night before it: when the user is likely to wake on
/// their own, the smart alarm's wake window, and how much the night would add to or pay down
/// sleep debt against sleep need.
public struct AlarmSleepPreview: Hashable, Sendable {
    /// The ring this is about: the alarm's next one.
    public let ring: Date
    /// The habitual bedtime before the ring, or now if that has already passed.
    public let bedtime: Date
    /// The habitual wake nearest the ring, `Tuning.Alarm.wakeZoneHalfWidth` either side.
    public let wakeZone: DateInterval
    /// The smart alarm's window, ending at the ring.
    public let window: DateInterval
    /// Sleep need minus the night from bedtime to the ring: positive adds to debt, otherwise pays it down.
    public let debtChange: TimeInterval
    /// True while the times stand on the user's usual times rather than their nights.
    public let isLearning: Bool

    /// `now`, when given, stands in for a bedtime already past, since no more sleep than from now
    /// to the ring is left.
    public init(ring: Date, habitual: HabitualSleep, need: TimeInterval, windowMinutes: Int, now: Date? = nil, calendar: Calendar) {
        self.ring = ring
        var bedtime = habitual.bedtime.date(on: ring, calendar: calendar)
        while bedtime >= ring { bedtime = calendar.date(byAdding: .day, value: -1, to: bedtime) ?? ring.addingTimeInterval(-24 * 3600) }
        if let now, now > bedtime, now < ring { bedtime = now }
        self.bedtime = bedtime
        let wake = Self.wake(nearest: ring, habitual: habitual, calendar: calendar)
        let half = Tuning.Alarm.wakeZoneHalfWidth
        wakeZone = DateInterval(start: wake.addingTimeInterval(-half), end: wake.addingTimeInterval(half))
        window = DateInterval(start: ring.addingTimeInterval(-TimeInterval(windowMinutes) * 60), end: ring)
        // To the minute, as the line shows it, so a night that meets need reads as meeting it.
        debtChange = ((need - ring.timeIntervalSince(bedtime)) / 60).rounded() * 60
        isLearning = habitual.isLearning
    }

    /// True when the ring comes before the wake zone opens, which cuts the night short.
    public var isEarly: Bool { ring < wakeZone.start }

    /// True when the night falls short of need.
    public var addsDebt: Bool { debtChange > 0 }

    /// True when the night is exactly the need, to the minute.
    public var meetsNeed: Bool { debtChange == 0 }

    /// False when the alarm is too far from bedtime to end a night, such as an afternoon alarm, so
    /// it says nothing about sleep debt.
    public var endsANight: Bool { ring.timeIntervalSince(bedtime) <= Tuning.Alarm.longestNight }

    /// Where the marker may be dragged and still mean this night: after bedtime, late enough for the
    /// system to set it, and on the ring's own day. When today can ring too, only up to now's clock
    /// time, since a later time today would make today's the next ring.
    public func dragRange(for alarm: AlarmSettings, now: Date, calendar: Calendar) -> ClosedRange<Date> {
        let step = Tuning.Alarm.dragStep
        let day = calendar.startOfDay(for: ring)
        let soonest = Self.snap(now.addingTimeInterval(Tuning.Alarm.minimumLeadTime + step / 2))
        let afterBed = Date(timeIntervalSinceReferenceDate: (bedtime.addingTimeInterval(step).timeIntervalSinceReferenceDate / step).rounded(.up) * step)
        let lower = max(day, afterBed, soonest)
        var upper = (calendar.date(byAdding: .day, value: 1, to: day) ?? day).addingTimeInterval(-step)
        let daysAhead = calendar.dateComponents([.day], from: calendar.startOfDay(for: now), to: day).day ?? 0
        let todayRings = !alarm.repeats || alarm.repeatDays.contains { $0.rawValue == calendar.component(.weekday, from: now) }
        if daysAhead > 0, todayRings, let sameClock = calendar.date(byAdding: .day, value: daysAhead, to: now) {
            upper = min(upper, Date(timeIntervalSinceReferenceDate: (sameClock.timeIntervalSinceReferenceDate / step).rounded(.down) * step))
        }
        return lower <= upper ? lower...upper : ring...ring
    }

    /// A dragged alarm time, on the nearest `Tuning.Alarm.dragStep`.
    public static func snap(_ date: Date) -> Date {
        let step = Tuning.Alarm.dragStep
        return Date(timeIntervalSinceReferenceDate: (date.timeIntervalSinceReferenceDate / step).rounded() * step)
    }

    /// The habitual wake closest to the ring, so a ring just before midnight finds that morning's zone.
    static func wake(nearest ring: Date, habitual: HabitualSleep, calendar: Calendar) -> Date {
        let sameDay = habitual.wakeTime.date(on: ring, calendar: calendar)
        let candidates = [-1, 0, 1].compactMap { calendar.date(byAdding: .day, value: $0, to: sameDay) }
        return candidates.min { abs($0.timeIntervalSince(ring)) < abs($1.timeIntervalSince(ring)) } ?? sameDay
    }
}
