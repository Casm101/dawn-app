import DawnHealth
import SwiftUI

@main
struct DawnApp: App {
    @State private var sleep = SleepStore(
        access: HealthKitAccess(),
        feed: SleepSessionFeed(source: HealthKitSleepSource())
    )

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(sleep)
        }
    }
}
