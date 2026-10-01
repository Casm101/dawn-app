import DawnAlarmKit
import DawnCore
import DawnSync
import Foundation

/// Takes each outcome the Watch sends: stands the alarm's ring down when the Watch woke the wearer
/// first, then adds the outcome to the history.
@MainActor
struct WakeOutcomeRelay {
    let channel: any WakeOutcomeChannel
    let alarms: AlarmLibrary
    let history: WakeHistoryStore

    func run() async {
        for await outcome in channel.outcomes {
            await alarms.received(outcome)
            history.record(outcome)
        }
    }
}
