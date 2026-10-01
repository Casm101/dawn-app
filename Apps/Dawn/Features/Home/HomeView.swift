import DawnAlarmKit
import DawnCore
import DawnHealth
import DawnUI
import SwiftUI

/// The first tab: last night and recent naps, or the Health prompt until it has been answered.
struct HomeView: View {
    @Environment(SleepStore.self) private var sleep
    @Environment(NeedStore.self) private var needs
    @Environment(AlarmLibrary.self) private var alarms

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
                ToolbarItem(placement: .topBarLeading) { ProfileButton() }
                ToolbarItem(placement: .primaryAction) { AlarmPill() }
            }
        }
        .onChange(of: sleep.sessions, initial: true) { learnNeed() }
        .onChange(of: alarms.hasLoaded) { learnNeed() }
    }

    /// Need learns only from nights checked against a loaded alarm list, never an empty one by mistake.
    private func learnNeed() {
        guard alarms.hasLoaded, !alarms.isReadOnly else { return }
        needs.learn(from: sleep.sessions, alarms: alarms.alarms)
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
            if let debt = DebtSummary(sessions: sleep.sessions, need: needs.need.value, now: Date(), calendar: .current) {
                DebtCard(summary: debt)
            }
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
