import Foundation

/// What a chosen alarm time means for the night before it: when the user is likely to wake on
/// their own, the smart alarm's wake window, and how much the night would add to or pay down
/// sleep debt against sleep need.
public struct AlarmSleepPreview: Hashable, Sendable {
    /// The ring this is about: the alarm's next one.
    public let ring: Date
    /// The habitual bedtime before the ring.
    public let bedtime: Date
    /// The habitual wake on the ring's day, `Tuning.Alarm.wakeZoneHalfWidth` either side.
    public let wakeZone: DateInterval
    /// The smart alarm's window, ending at the ring.
    public let window: DateInterval
    /// Sleep need minus the night from bedtime to the ring: positive adds to debt, otherwise pays it down.
    public let debtChange: TimeInterval
    /// True while the times stand on the user's usual times rather than their nights.
    public let isLearning: Bool

    public init(ring: Date, habitual: HabitualSleep, need: TimeInterval, windowMinutes: Int, calendar: Calendar) {
        self.ring = ring
        var bedtime = habitual.bedtime.date(on: ring, calendar: calendar)
        while bedtime >= ring { bedtime = calendar.date(byAdding: .day, value: -1, to: bedtime) ?? ring.addingTimeInterval(-24 * 3600) }
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

    /// Where the marker may be dragged and still mean this night: on the ring's own day, so the next
    /// ring stays on it, after bedtime, and late enough for the system to set it.
    public func dragRange(now: Date, calendar: Calendar) -> ClosedRange<Date> {
        let day = calendar.startOfDay(for: ring)
        let soonest = Self.snap(now.addingTimeInterval(Tuning.Alarm.minimumLeadTime + Tuning.Alarm.dragStep / 2))
        let lower = max(day, bedtime.addingTimeInterval(Tuning.Alarm.dragStep), soonest)
        let dayEnd = (calendar.date(byAdding: .day, value: 1, to: day) ?? day).addingTimeInterval(-Tuning.Alarm.dragStep)
        return lower <= dayEnd ? lower...dayEnd : ring...ring
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
