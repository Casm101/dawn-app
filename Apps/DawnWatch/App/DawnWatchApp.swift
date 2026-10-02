import DawnCore
import DawnHealth
import DawnSync
import DawnWrist
import SwiftUI
import WatchKit

@main
struct DawnWatchApp: App {
    @WKApplicationDelegateAdaptor private var delegate: WatchAppDelegate
    @Environment(\.scenePhase) private var scenePhase
    @State private var alarms: WatchAlarmStore
    @State private var alarmSync: AlarmSyncEngine
    @State private var wake: WakeCoordinator
    private let channel: WatchConnectivityChannel

    init() {
        let channel = WatchConnectivityChannel()
        let alarms = WatchAlarmStore(file: JSONFile(url: .applicationSupportDirectory.appending(path: "alarms.json")))
        let alarmSync = AlarmSyncEngine(
            channel: channel, replica: .watch, store: alarms,
            progressFile: JSONFile(url: .applicationSupportDirectory.appending(path: "alarm-sync.json"))
        )
        let session = ExtendedRuntimeWakeSession()
        let wake = WakeCoordinator(
            session: session, motion: DeviceMotionStream(), heart: PassiveHeartRateStream(),
            nudges: SystemWakeNudges(title: WakeCopy.nudgeTitle, body: WakeCopy.nudgeBody),
            alarms: { alarms.alarms }, send: { channel.send($0) },
            isActive: { WKApplication.shared().applicationState == .active }, folder: .applicationSupportDirectory
        )
        // Any change to the alarms, here or from the phone, moves or stands down the armed window.
        alarms.onLocalChange = {
            alarmSync.localDidChange()
            Task { await wake.follow() }
        }
        alarms.onRemoteChange = { Task { await wake.follow() } }
        self.channel = channel
        _alarms = State(initialValue: alarms)
        _alarmSync = State(initialValue: alarmSync)
        _wake = State(initialValue: wake)
        WakeSessionInbox.shared.receive { session.attach($0) }
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
