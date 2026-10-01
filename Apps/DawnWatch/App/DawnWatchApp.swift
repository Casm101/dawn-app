import DawnCore
import DawnHealth
import DawnSync
import DawnWrist
import SwiftUI

@main
struct DawnWatchApp: App {
    @WKApplicationDelegateAdaptor private var delegate: WatchAppDelegate
    @Environment(\.scenePhase) private var scenePhase
    @State private var alarms: WatchAlarmStore
    @State private var alarmSync: AlarmSyncEngine
    @State private var wake: WakeController
    private let channel: WatchConnectivityChannel

    init() {
        let channel = WatchConnectivityChannel()
        let alarms = WatchAlarmStore(file: JSONFile(url: .applicationSupportDirectory.appending(path: "alarms.json")))
        let alarmSync = AlarmSyncEngine(
            channel: channel, replica: .watch, store: alarms,
            progressFile: JSONFile(url: .applicationSupportDirectory.appending(path: "alarm-sync.json"))
        )
        let wake = WakeController(
            alarms: alarms, channel: channel, motion: DeviceMotionStream(), heart: PassiveHeartRateStream(),
            folder: .applicationSupportDirectory
        )
        alarms.onLocalChange = { alarmSync.localDidChange() }
        alarms.onRemoteChange = { Task { await wake.refreshNudge() } }
        self.channel = channel
        _alarms = State(initialValue: alarms)
        _alarmSync = State(initialValue: alarmSync)
        _wake = State(initialValue: wake)
        WakeSessionInbox.shared.receive { wake.session.attach($0) }
        Task { await alarmSync.run() }
        Task { await wake.run() }
    }

    var body: some Scene {
        WindowGroup {
            WatchAlarmList()
                .environment(alarms)
                .environment(alarmSync)
                .environment(wake)
        }
        // A session may only be scheduled from the foreground, so every activation arms.
        .onChange(of: scenePhase, initial: true) { _, phase in
            guard phase == .active else { return }
            Task { await wake.activate() }
        }
        .backgroundTask(.watchConnectivity) {
            await channel.waitForPendingContent()
        }
    }
}
