import Foundation

extension AlarmDefinition {
    /// The latest edit to any of the alarm's settings.
    public var lastEdited: Date {
        [enabled.updatedAt, wakeTime.updatedAt, repeatDays.updatedAt, sound.updatedAt, snoozeMinutes.updatedAt,
         windowMinutes.updatedAt].max() ?? .distantPast
    }

    /// This alarm with each field taken from `other` where `preferTheirs` says so.
    func merged(with other: AlarmDefinition, preferTheirs: (Date, Date, Replica, Replica) -> Bool) -> AlarmDefinition {
        func pick<V>(_ mine: Stamped<V>, _ theirs: Stamped<V>) -> Stamped<V> {
            preferTheirs(mine.updatedAt, theirs.updatedAt, mine.origin, theirs.origin) ? theirs : mine
        }
        var result = self
        result.enabled = pick(enabled, other.enabled)
        result.wakeTime = pick(wakeTime, other.wakeTime)
        result.repeatDays = pick(repeatDays, other.repeatDays)
        result.sound = pick(sound, other.sound)
        result.snoozeMinutes = pick(snoozeMinutes, other.snoozeMinutes)
        result.windowMinutes = pick(windowMinutes, other.windowMinutes)
        return result
    }
}
