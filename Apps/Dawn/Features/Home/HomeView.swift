import DawnCore
import DawnHealth
import DawnUI
import SwiftUI

/// The first tab: last night and recent naps, or the Health prompt until it has been answered.
struct HomeView: View {
    @Environment(SleepStore.self) private var sleep
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: DawnSpacing.lg) {
                    content
                }
                .padding(DawnSpacing.lg)
            }
            .navigationTitle(String(localized: "home.title", defaultValue: "Home"))
            .toolbar {
                ToolbarItem(placement: .primaryAction) { AlarmPill() }
            }
        }
        .task { await sleep.refreshAccess() }
        .task(id: sleep.access) { await sleep.follow() }
        .onChange(of: scenePhase) { _, phase in
            guard phase == .active else { return }
            Task { await sleep.reload() }
        }
    }

    @ViewBuilder private var content: some View {
        switch sleep.access {
        case nil:
            ProgressView()
        case .notDetermined:
            HealthConnectCard { Task { await sleep.connect() } }
        case .unavailable:
            HealthUnavailableCard()
        case .granted, .denied:
            let recent = sleep.recent
            if let night = recent.lastNight {
                LastNightCard(night: night)
            } else if !sleep.hasLoaded {
                ProgressView()
            } else if recent.isEmpty {
                NoRecentSleepCard()
            }
            if !recent.naps.isEmpty {
                NapsCard(naps: recent.naps)
            }
        }
    }
}
