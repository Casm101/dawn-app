import DawnAlarmKit
import DawnCore
import DawnHealth
import DawnSync
import DawnUI
import SwiftUI
import UserNotifications

@main
struct DawnApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @State private var edits: SleepEditsStore
    @State private var sleep: SleepStore
    @State private var needs = NeedStore(
        file: JSONFile(url: .applicationSupportDirectory.appending(path: "sleep-need.json"))
    )
    @State private var usual = UsualSleepStore(
        file: JSONFile(url: .applicationSupportDirectory.appending(path: "usual-sleep.json"))
    )
    @State private var forecaster = EnergyForecaster()
    @State private var alarms: AlarmLibrary
    @State private var alarmSync: AlarmSyncEngine
    @State private var habits = HabitStore(
        file: JSONFile(url: .applicationSupportDirectory.appending(path: "habit-settings.json"))
    )
    @State private var ratings = RatingStore(
        file: JSONFile(url: .applicationSupportDirectory.appending(path: "night-ratings.json"))
    )
    @State private var router: HabitRouter
    @State private var reminders: HabitReminderScheduler
    /// Kept here because the notification centre holds its delegate weakly.
    private let reminderCenter: NotificationReminderCenter

    init() {
        let edits = SleepEditsStore(file: JSONFile(url: .applicationSupportDirectory.appending(path: "sleep-edits.json")))
        _edits = State(initialValue: edits)
        _sleep = State(initialValue: SleepStore(
            access: HealthKitAccess(), feed: SleepSessionFeed(source: HealthKitSleepSource()), edits: edits
        ))
        let alarms = AlarmLibrary(
            file: JSONFile(url: .applicationSupportDirectory.appending(path: "alarms.json")),
            sync: AlarmSystemSync(
                scheduler: AlarmKitScheduler(copy: .dawn, tint: DawnColor.accent),
                linksFile: JSONFile(url: .applicationSupportDirectory.appending(path: "alarm-links.json"))
            ),
            authorizer: AlarmKitAuthorizer()
        )
        let alarmSync = AlarmSyncEngine(
            channel: WatchConnectivityChannel(), replica: .phone, store: alarms,
            progressFile: JSONFile(url: .applicationSupportDirectory.appending(path: "alarm-sync.json"))
        )
        alarms.onLocalChange = { alarmSync.localDidChange() }
        _alarms = State(initialValue: alarms)
        _alarmSync = State(initialValue: alarmSync)
        let router = HabitRouter()
        let reminderCenter = NotificationReminderCenter { habit in
            Task { @MainActor in router.open(habit) }
        }
        // Set before launch finishes, so a tapped reminder that launched Dawn is still delivered.
        UNUserNotificationCenter.current().delegate = reminderCenter
        self.reminderCenter = reminderCenter
        _router = State(initialValue: router)
        _reminders = State(initialValue: HabitReminderScheduler(
            center: reminderCenter, file: JSONFile(url: .applicationSupportDirectory.appending(path: "habit-reminders.json"))
        ))
        // Started here rather than from a view, so a launch in the background to take a change from
        // the Watch still reads the alarms and moves their system alarms.
        Task {
            await alarms.load()
            await alarmSync.run()
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(sleep)
                .environment(edits)
                .environment(alarms)
                .environment(needs)
                .environment(usual)
                .environment(forecaster)
                .environment(alarmSync)
                .environment(habits)
                .environment(ratings)
                .environment(router)
                .environment(reminders)
        }
        .onChange(of: scenePhase) { _, phase in
            guard phase == .active else { return }
            Task { await alarms.load() }
        }
    }
}
