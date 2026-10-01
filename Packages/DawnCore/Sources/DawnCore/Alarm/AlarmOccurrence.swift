import Foundation

/// When an alarm next rings, and whether that is too soon for the system to honour.
public enum AlarmOccurrence {
    /// The first time strictly after `now` that the alarm's time falls on one of its days.
    public static func next(_ alarm: AlarmSettings, after now: Date, calendar: Calendar) -> Date? {
        var components = DateComponents(hour: alarm.time.hour, minute: alarm.time.minute, second: 0)
        guard alarm.repeats else {
            return calendar.nextDate(after: now, matching: components, matchingPolicy: .nextTime)
        }
        return alarm.repeatDays.compactMap { day -> Date? in
            components.weekday = day.rawValue
            return calendar.nextDate(after: now, matching: components, matchingPolicy: .nextTime)
        }.min()
    }

    /// True when the alarm, as set now, rings at exactly `date`.
    public static func rings(_ alarm: AlarmSettings, at date: Date, calendar: Calendar) -> Bool {
        next(alarm, after: date.addingTimeInterval(-1), calendar: calendar) == date
    }

    /// Nil when the next ring is at least `Tuning.Alarm.minimumLeadTime` away.
    public static func leadTimeProblem(
        _ alarm: AlarmSettings, after now: Date, calendar: Calendar
    ) -> LeadTimeProblem? {
        guard let next = next(alarm, after: now, calendar: calendar),
              next.timeIntervalSince(now) < Tuning.Alarm.minimumLeadTime else { return nil }
        guard alarm.repeats, let following = self.next(alarm, after: next, calendar: calendar) else {
            return .tooCloseToSet
        }
        return .nextRingTooClose(skipped: next, following: following)
    }
}
