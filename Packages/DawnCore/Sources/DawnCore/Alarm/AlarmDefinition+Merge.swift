import Foundation

extension AlarmDefinition {
    /// Whether the alarm outlives a deletion. An edit after the deletion keeps it; an edit before it
    /// does not. At the same instant the phone's side wins, and a deletion beats an edit the same
    /// device made with it. Switching the alarm off never keeps it: a deleted alarm is already off,
    /// and the phone switches off alarms on its own, for example a one-off that has rung.
    public func outlives(_ tombstone: Tombstone) -> Bool {
        let edits = enabled.value ? stamps : Array(stamps.dropFirst())
        let latest = edits.map(\.at).max() ?? .distantPast
        if latest != tombstone.deletedAt { return latest > tombstone.deletedAt }
        return edits.contains { stamp in
            stamp.at == tombstone.deletedAt && stamp.by != tombstone.origin && stamp.by.winsTie(against: tombstone.origin)
        }
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

    /// When and on which device each setting was last edited, the switch first.
    private var stamps: [(at: Date, by: Replica)] {
        [
            (enabled.updatedAt, enabled.origin), (wakeTime.updatedAt, wakeTime.origin),
            (repeatDays.updatedAt, repeatDays.origin), (sound.updatedAt, sound.origin),
            (snoozeMinutes.updatedAt, snoozeMinutes.origin), (windowMinutes.updatedAt, windowMinutes.origin),
        ]
    }
}
