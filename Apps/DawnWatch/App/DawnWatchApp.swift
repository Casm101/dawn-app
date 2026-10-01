import DawnCore
import DawnSync
import SwiftUI

@main
struct DawnWatchApp: App {
    @State private var alarms: WatchAlarmStore
    @State private var alarmSync: AlarmSyncEngine

    init() {
        let alarms = WatchAlarmStore(file: JSONFile(url: .applicationSupportDirectory.appending(path: "alarms.json")))
        let alarmSync = AlarmSyncEngine(
            channel: WatchConnectivityChannel(), replica: .watch, store: alarms,
            progressFile: JSONFile(url: .applicationSupportDirectory.appending(path: "alarm-sync.json"))
        )
        alarms.onLocalChange = { alarmSync.localDidChange() }
        _alarms = State(initialValue: alarms)
        _alarmSync = State(initialValue: alarmSync)
        Task { await alarmSync.run() }
    }

    var body: some Scene {
        WindowGroup {
            WatchAlarmList()
                .environment(alarms)
                .environment(alarmSync)
        }
    }
}
