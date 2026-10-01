import DawnCore
import DawnSync
import SwiftUI

@main
struct DawnWatchApp: App {
    @State private var alarms: WatchAlarmStore
    @State private var alarmSync: AlarmSyncEngine

    init() {
        let alarms = WatchAlarmStore(file: JSONFile(url: .applicationSupportDirectory.appending(path: "alarms.json")))
        let alarmSync = AlarmSyncEngine(channel: WatchConnectivityChannel(), replica: .watch, store: alarms)
        alarms.onLocalChange = { alarmSync.localDidChange() }
        _alarms = State(initialValue: alarms)
        _alarmSync = State(initialValue: alarmSync)
    }

    var body: some Scene {
        WindowGroup {
            WatchAlarmList()
                .environment(alarms)
                .environment(alarmSync)
                .task { await alarmSync.run() }
        }
    }
}
