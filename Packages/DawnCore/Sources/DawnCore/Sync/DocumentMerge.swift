import Foundation

/// Merges two copies of the alarm document field by field: the newer edit wins, and a tie goes to the
/// phone. A deletion wins over every edit
/// made before it, and an edit made after it brings the alarm back (see `AlarmDefinition.outlives`).
public enum DocumentMerge {
    public static func merge(_ local: AlarmDocument, _ remote: AlarmDocument) -> AlarmDocument {
        let ids = Set(local.alarms.map(\.id)).union(remote.alarms.map(\.id))
            .union(local.tombstones.map(\.id)).union(remote.tombstones.map(\.id))
        var alarms: [AlarmDefinition] = []
        var tombstones: [Tombstone] = []
        for id in ids {
            let tomb = newer(local.tombstone(id), remote.tombstone(id))
            let alarm = merged(local.alarm(id), remote.alarm(id))
            if let tomb, !(alarm?.outlives(tomb) ?? false) {
                tombstones.append(tomb)
            } else if let alarm {
                alarms.append(alarm)
            }
        }
        return AlarmDocument(
            alarms: alarms, tombstones: tombstones,
            revision: max(local.revision, remote.revision), updatedAt: max(local.updatedAt, remote.updatedAt),
            origin: local.origin
        )
    }

    private static func merged(_ mine: AlarmDefinition?, _ theirs: AlarmDefinition?) -> AlarmDefinition? {
        guard let mine, let theirs else { return mine ?? theirs }
        return mine.merged(with: theirs) { mineAt, theirsAt, mineBy, theirsBy in
            prefers(theirsAt, theirsBy, over: mineAt, mineBy)
        }
    }

    /// The later deletion, or the phone's when both deleted at the same instant, so both devices agree.
    private static func newer(_ a: Tombstone?, _ b: Tombstone?) -> Tombstone? {
        guard let a, let b else { return a ?? b }
        return prefers(b.deletedAt, b.origin, over: a.deletedAt, a.origin) ? b : a
    }

    /// Whether one edit beats another: the later one, or the phone's when both carry the same time.
    private static func prefers(_ at: Date, _ by: Replica, over otherAt: Date, _ otherBy: Replica) -> Bool {
        if at != otherAt { return at > otherAt }
        return by != otherBy && by.winsTie(against: otherBy)
    }
}
