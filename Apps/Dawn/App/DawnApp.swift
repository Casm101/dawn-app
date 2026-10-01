import DawnAlarmKit
import DawnCore
import DawnHealth
import DawnUI
import SwiftUI

@main
struct DawnApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @State private var sleep = SleepStore(
        access: HealthKitAccess(),
        feed: SleepSessionFeed(source: HealthKitSleepSource())
    )
    @State private var alarms = AlarmLibrary(
        file: JSONFile(url: .applicationSupportDirectory.appending(path: "alarms.json")),
        sync: AlarmSystemSync(
            scheduler: AlarmKitScheduler(copy: .dawn, tint: DawnColor.accent),
            linksFile: JSONFile(url: .applicationSupportDirectory.appending(path: "alarm-links.json"))
        ),
        authorizer: AlarmKitAuthorizer()
    )

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(sleep)
                .environment(alarms)
                .task { await alarms.load() }
        }
        .onChange(of: scenePhase) { _, phase in
            guard phase == .active else { return }
            Task { await alarms.load() }
        }
    }
}
