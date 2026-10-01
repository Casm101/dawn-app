import DawnAlarmKit
import DawnCore
import DawnHealth
import DawnUI
import SwiftUI

/// The first tab: sleep debt, energy potential, the day's phases, last night and recent naps, or the
/// Health prompt until it has been answered.
struct HomeView: View {
    @Environment(SleepStore.self) private var sleep
    @Environment(SleepEditsStore.self) private var edits
    @Environment(NeedStore.self) private var needs
    @Environment(AlarmLibrary.self) private var alarms
    @Environment(UsualSleepStore.self) private var usual
    @Environment(EnergyForecaster.self) private var forecaster

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
                EnergyPotentialCard(percent: EnergyPotential.percent(debtHours: debt.hours))
            }
            if sleep.hasLoaded {
                TimelineView(.periodic(from: .now, by: 60)) { context in
                    let forecast = forecaster.forecast(sessions: sleep.sessions, usual: usual.usual, now: context.date)
                    PhaseCarousel(
                        cards: PhaseCard.cards(for: forecast, now: context.date, calendar: .current),
                        isLearning: forecast.today.isLearning
                    )
                }
            }
            if let night = recent.lastNight {
                LastNightCard(night: night, isEdited: edits.edits.correction(for: CalendarDay(night.evening, calendar: .current)) != nil)
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
