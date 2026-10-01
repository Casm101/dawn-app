import DawnCore
import Foundation
@testable import DawnSync

/// A device's alarm document held in memory.
@MainActor
final class FakeAlarmStore: SyncedAlarmStore {
    private(set) var document = AlarmDocument()
    let replica: Replica

    init(replica: Replica) { self.replica = replica }

    func documentForSending(at now: Date) -> AlarmDocument {
        document.bump(at: now, by: replica)
        return document
    }

    func applyRemote(_ document: AlarmDocument) async { self.document = document }

    func edit(_ id: UUID, at now: Date = Date(), _ change: (inout AlarmSettings) -> Void) {
        var settings = document.alarm(id)?.settings ?? AlarmSettings(time: ClockTime(hour: 7, minute: 0)!)
        change(&settings)
        document.save(settings, id: id, at: now, by: replica)
    }
}
