import DawnCore
import Foundation
import Observation

/// Keeps this device's alarm document in step with the other device's: sends every local change,
/// merges every copy that arrives, sends back only what the other side lacks, and knows whether the
/// other side has seen the latest change.
@MainActor
@Observable
public final class AlarmSyncEngine {
    /// True while the other device has not acknowledged this device's latest document.
    public private(set) var isWaiting = false
    private var lastSent = 0
    private var lastAcknowledged = 0
    @ObservationIgnored private let channel: any AlarmDocumentChannel
    @ObservationIgnored private let replica: Replica
    @ObservationIgnored private weak var store: (any SyncedAlarmStore)?

    public init(channel: any AlarmDocumentChannel, replica: Replica, store: any SyncedAlarmStore) {
        self.channel = channel
        self.replica = replica
        self.store = store
    }

    /// Refreshes the other device's copy, then merges copies and acknowledgements until cancelled.
    /// The refresh is not a change made here, so it does not leave this device waiting.
    public func run() async {
        await channel.activate()
        await send(counts: false)
        let channel = channel
        await withTaskGroup(of: Void.self) { group in
            group.addTask { for await document in channel.documents { await self.receive(document) } }
            group.addTask { for await revision in channel.acknowledgements { await self.acknowledged(revision) } }
        }
    }

    public func localDidChange() {
        Task { await send(counts: true) }
    }

    func receive(_ remote: AlarmDocument) async {
        guard let store else { return }
        let decision = SyncDecision(local: store.document, remote: remote, at: Date(), by: replica)
        if decision.changedHere || decision.sendBack {
            await store.applyRemote(decision.document)
        }
        channel.acknowledge(remote.revision)
        if decision.sendBack { await send(counts: true) }
    }

    func acknowledged(_ revision: Int) async {
        lastAcknowledged = max(lastAcknowledged, revision)
        await refreshWaiting()
    }

    private func send(counts: Bool) async {
        guard let store else { return }
        let document = store.documentForSending(at: Date())
        // A failed send still counts as unacknowledged, so the device shows it is waiting.
        try? channel.publish(document)
        if counts { lastSent = max(lastSent, document.revision) }
        await refreshWaiting()
    }

    private func refreshWaiting() async {
        isWaiting = lastAcknowledged < lastSent ? await channel.counterpartAvailable() : false
    }
}
