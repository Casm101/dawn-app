import DawnCore
import DawnSync
import Foundation
import Observation

/// The Watch's copy of the alarm document, saved on the Watch and kept in step with the phone's.
@MainActor
@Observable
final class WatchAlarmStore: SyncedAlarmStore {
    private(set) var document: AlarmDocument
    /// Called after every change made on the Watch, so it can be sent to the phone.
    @ObservationIgnored var onLocalChange: (() -> Void)?
    /// Called after a copy from the phone is taken, so the wake window can follow it.
    @ObservationIgnored var onRemoteChange: (() -> Void)?
    @ObservationIgnored private let file: JSONFile<AlarmDocument>

    init(file: JSONFile<AlarmDocument>) {
        self.file = file
        // An unreadable copy starts empty: the phone's copy fills it in, and an empty copy deletes nothing.
        document = (try? file.read()) ?? AlarmDocument(origin: .watch)
    }

    var alarms: [AlarmDefinition] { document.alarms }

    func save(_ settings: AlarmSettings, id: UUID) {
        document.save(settings, id: id, at: Date(), by: .watch)
        persist()
        onLocalChange?()
    }

    func delete(_ id: UUID) {
        document.remove(id, at: Date(), by: .watch)
        persist()
        onLocalChange?()
    }

    func documentForSending(at now: Date) -> AlarmDocument {
        document.bump(at: now, by: .watch)
        persist()
        return document
    }

    func applyRemote(_ document: AlarmDocument, at now: Date) async -> Bool {
        self.document = document
        persist()
        onRemoteChange?()
        return false
    }

    private func persist() {
        try? file.write(document)
    }
}
