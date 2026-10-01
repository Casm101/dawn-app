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
    @State private var usual = UsualSleepStore(
        file: JSONFile(url: .applicationSupportDirectory.appending(path: "usual-sleep.json"))
    )
    @State private var forecaster = EnergyForecaster()
    @State private var history: WakeHistoryStore
    @State private var alarms: AlarmLibrary
    @State private var alarmSync: AlarmSyncEngine

    init() {
        let channel = WatchConnectivityChannel()
        let alarms = AlarmLibrary(
            file: JSONFile(url: .applicationSupportDirectory.appending(path: "alarms.json")),
            sync: AlarmSystemSync(
                scheduler: AlarmKitScheduler(copy: .dawn, tint: DawnColor.accent),
                linksFile: JSONFile(url: .applicationSupportDirectory.appending(path: "alarm-links.json")),
                skipsFile: JSONFile(url: .applicationSupportDirectory.appending(path: "alarm-skips.json"))
            ),
            authorizer: AlarmKitAuthorizer()
        )
        let alarmSync = AlarmSyncEngine(
            channel: channel, replica: .phone, store: alarms,
            progressFile: JSONFile(url: .applicationSupportDirectory.appending(path: "alarm-sync.json"))
        )
        alarms.onLocalChange = { alarmSync.localDidChange() }
        _alarms = State(initialValue: alarms)
        _alarmSync = State(initialValue: alarmSync)
        let history = WakeHistoryStore(file: JSONFile(url: .applicationSupportDirectory.appending(path: "wake-history.json")))
        _history = State(initialValue: history)
        let relay = WakeOutcomeRelay(channel: channel, alarms: alarms, history: history)
        // Started here rather than from a view, so a launch in the background to take a change from
        // the Watch still reads the alarms and moves their system alarms.
        Task {
            await alarms.load()
            await alarmSync.run()
        }
        // Outcomes only arrive once the session is active, which `run` does after loading.
        Task { await relay.run() }
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(sleep)
                .environment(alarms)
                .environment(needs)
                .environment(usual)
                .environment(forecaster)
                .environment(alarmSync)
                .environment(history)
        }
        .onChange(of: scenePhase) { _, phase in
            guard phase == .active else { return }
            Task { await alarms.load() }
        }
    }
}
