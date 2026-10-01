import Foundation

/// Merges two copies of the alarm document field by field: the newer edit wins; on a tie the copy
/// with the higher revision wins; on a further tie the phone wins. A deletion wins over every edit
/// made before it, and an edit made after it brings the alarm back (see `AlarmDefinition.outlives`).
public enum DocumentMerge {
    public static func merge(_ local: AlarmDocument, _ remote: AlarmDocument) -> AlarmDocument {
        let ids = Set(local.alarms.map(\.id)).union(remote.alarms.map(\.id))
            .union(local.tombstones.map(\.id)).union(remote.tombstones.map(\.id))
        var alarms: [AlarmDefinition] = []
        var tombstones: [Tombstone] = []
        for id in ids {
            let tomb = newer(local.tombstone(id), remote.tombstone(id))
            let alarm = merged(local.alarm(id), remote.alarm(id), local: local, remote: remote)
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

    private static func merged(
        _ mine: AlarmDefinition?, _ theirs: AlarmDefinition?, local: AlarmDocument, remote: AlarmDocument
    ) -> AlarmDefinition? {
        guard let mine, let theirs else { return mine ?? theirs }
        let preferTheirs: (Date, Date, Replica, Replica) -> Bool = { mineAt, theirsAt, mineBy, theirsBy in
            if mineAt != theirsAt { return theirsAt > mineAt }
            if local.revision != remote.revision { return remote.revision > local.revision }
            return theirsBy.winsTie(against: mineBy) && theirsBy != mineBy
        }
        return mine.merged(with: theirs, preferTheirs: preferTheirs)
    }

    private static func newer(_ a: Tombstone?, _ b: Tombstone?) -> Tombstone? {
        guard let a, let b else { return a ?? b }
        return b.deletedAt > a.deletedAt ? b : a
    }
}
