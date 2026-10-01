import DawnAlarmKit
import DawnCore
import DawnHealth
import DawnSync
import DawnUI
import SwiftUI

@main
struct DawnApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @State private var sleep = SleepStore(
        access: HealthKitAccess(),
        feed: SleepSessionFeed(source: HealthKitSleepSource())
    )
    @State private var needs = NeedStore(
        file: JSONFile(url: .applicationSupportDirectory.appending(path: "sleep-need.json"))
    )
    @State private var alarms: AlarmLibrary
    @State private var alarmSync: AlarmSyncEngine

    init() {
        let alarms = AlarmLibrary(
            file: JSONFile(url: .applicationSupportDirectory.appending(path: "alarms.json")),
            sync: AlarmSystemSync(
                scheduler: AlarmKitScheduler(copy: .dawn, tint: DawnColor.accent),
                linksFile: JSONFile(url: .applicationSupportDirectory.appending(path: "alarm-links.json"))
            ),
            authorizer: AlarmKitAuthorizer()
        )
        let alarmSync = AlarmSyncEngine(channel: WatchConnectivityChannel(), replica: .phone, store: alarms)
        alarms.onLocalChange = { alarmSync.localDidChange() }
        _alarms = State(initialValue: alarms)
        _alarmSync = State(initialValue: alarmSync)
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(sleep)
                .environment(alarms)
                .environment(needs)
                .environment(alarmSync)
                .task {
                    await alarms.load()
                    await alarmSync.run()
                }
        }
        .onChange(of: scenePhase) { _, phase in
            guard phase == .active else { return }
            Task { await alarms.load() }
        }
    }
}
