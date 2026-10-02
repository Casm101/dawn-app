import Foundation

extension AlarmDefinition {
    /// For an alarm that rings once, the ring it was set for: its time's first occurrence after it
    /// was last switched on, moved, or had its days changed. Nil for a repeating alarm.
    public func onceRing(calendar: Calendar) -> Date? {
        guard !settings.repeats else { return nil }
        let set = max(enabled.updatedAt, wakeTime.updatedAt, repeatDays.updatedAt)
        return AlarmOccurrence.next(settings, after: set, calendar: calendar)
    }
}
