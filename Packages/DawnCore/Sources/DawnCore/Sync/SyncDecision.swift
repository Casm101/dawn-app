import Foundation

/// What a device does with a copy of the alarm document from the other device.
public struct SyncDecision: Sendable {
    /// The document to keep.
    public let document: AlarmDocument
    /// True when the merge changed this device's alarms, so they must be saved and applied.
    public let changedHere: Bool
    /// True when the merge holds something the other device lacks, so it must be sent back.
    public let sendBack: Bool

    public init(local: AlarmDocument, remote: AlarmDocument, at now: Date, by replica: Replica) {
        var merged = DocumentMerge.merge(local, remote)
        changedHere = !merged.sameContent(as: local)
        sendBack = !merged.sameContent(as: remote)
        merged.revision = max(local.revision, remote.revision)
        if changedHere || sendBack { merged.bump(at: now, by: replica) }
        document = merged
    }
}
