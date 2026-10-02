import DawnCore
import Foundation
import Observation

/// Every wake window's outcome the Watch has sent, kept on the phone and shown under each alarm.
@Observable
final class WakeHistoryStore {
    private(set) var log = WakeLog()
    private let file: JSONFile<WakeLog>

    init(file: JSONFile<WakeLog>) {
        self.file = file
        // An unreadable history starts empty; it is only ever shown, never acted on.
        log = (try? file.read()) ?? WakeLog()
    }

    func record(_ outcome: WakeOutcome) {
        log.record(outcome)
        try? file.write(log)
    }
}
