import DawnCore
import Foundation
import Observation

/// Keeps this device's alarm document in step with the other device's: sends every local change,
/// merges every copy that arrives, sends back only what the other side lacks, and knows whether the
/// other side has seen the latest change, across relaunches.
@MainActor
@Observable
public final class AlarmSyncEngine {
    /// True while the other device has not acknowledged this device's latest change.
    public private(set) var isWaiting = false
    @ObservationIgnored private var progress: SyncProgress {
        didSet { if progress != oldValue { try? progressFile?.write(progress) } }
    }
    /// The last copy that arrived, so the same copy delivered twice is merged once.
    @ObservationIgnored private var lastReceived: AlarmDocument?
    @ObservationIgnored private var hasStarted = false
    @ObservationIgnored private let channel: any AlarmDocumentChannel
    @ObservationIgnored private let replica: Replica
    @ObservationIgnored private weak var store: (any SyncedAlarmStore)?
    @ObservationIgnored private let progressFile: JSONFile<SyncProgress>?

    public init(
        channel: any AlarmDocumentChannel, replica: Replica, store: any SyncedAlarmStore,
        progressFile: JSONFile<SyncProgress>? = nil
    ) {
        self.channel = channel
        self.replica = replica
        self.store = store
        self.progressFile = progressFile
        progress = (try? progressFile?.read()) ?? SyncProgress()
    }

    /// Refreshes the other device's copy, then merges copies and acknowledgements until cancelled.
    /// The refresh is not a change made here, so it does not leave this device waiting. Runs once
    /// for the engine's life; a second call returns at once.
    public func run() async {
        guard !hasStarted else { return }
        hasStarted = true
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
        guard let store, remote != lastReceived else { return }
        lastReceived = remote
        let decision = SyncDecision(local: store.document, remote: remote, at: Date(), by: replica)
        var adjusted = false
        if decision.changedHere || decision.sendBack {
            adjusted = await store.applyRemote(decision.document, at: Date())
        }
        channel.acknowledge(remote.revision)
        if decision.sendBack || adjusted { await send(counts: true) }
    }

    func acknowledged(_ revision: Int) async {
        progress.acknowledged = max(progress.acknowledged, revision)
        await refreshWaiting()
    }

    private func send(counts: Bool) async {
        guard let store else { return }
        let document = store.documentForSending(at: Date())
        // A failed send still counts as unacknowledged, so the device shows it is waiting.
        try? channel.publish(document)
        if counts { progress.sent = max(progress.sent, document.revision) }
        await refreshWaiting()
    }

    private func refreshWaiting() async {
        isWaiting = progress.acknowledged < progress.sent ? await channel.counterpartAvailable() : false
    }
}
