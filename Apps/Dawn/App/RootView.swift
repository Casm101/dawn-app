import DawnCore
import SwiftUI

/// The five tabs. Each shows a placeholder until its ticket lands. Health is followed here, not in
/// a tab, so every tab sees new sleep whichever one is showing, and habit reminders follow the
/// schedule from here too.
struct RootView: View {
    @Environment(SleepStore.self) private var sleep
    @Environment(UsualSleepStore.self) private var usual
    @Environment(EnergyForecaster.self) private var forecaster
    @Environment(HabitStore.self) private var habits
    @Environment(HabitReminderScheduler.self) private var reminders
    @Environment(HabitRouter.self) private var router
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        @Bindable var router = router
        TabView(selection: $router.tab) {
            Tab("Home", systemImage: "house", value: RootTab.home) { HomeView() }
            Tab("Progress", systemImage: "chart.line.uptrend.xyaxis", value: RootTab.progress) { SleepProgressView() }
            Tab("Energy", systemImage: "list.bullet", value: RootTab.energy) { EnergyView() }
            Tab("Tools", systemImage: "briefcase", value: RootTab.tools) { ToolsView() }
            Tab("Guidance", systemImage: "bubble", value: RootTab.guidance) { placeholder("Guidance") }
        }
        .task { await sleep.refreshAccess() }
        .task(id: sleep.access) { await sleep.follow() }
        .onChange(of: scenePhase) { _, phase in
            guard phase == .active else { return }
            Task { await sleep.reload() }
            // Forced, in case notifications were allowed in Settings while Dawn was away.
            scheduleReminders(force: true)
        }
        .onChange(of: habits.settings, initial: true) { scheduleReminders() }
        .onChange(of: sleep.sessions) { scheduleReminders() }
        .onChange(of: usual.usual) { scheduleReminders() }
    }

    private func scheduleReminders(force: Bool = false) {
        let now = Date()
        let days = forecaster.forecast(sessions: sleep.sessions, usual: usual.usual, now: now).days
        reminders.update(days: days, settings: habits.settings, now: now, force: force)
    }

    private func placeholder(_ title: String) -> some View {
        ContentUnavailableView(title, systemImage: "moon.zzz", description: Text("Coming in a later ticket."))
    }
}

#Preview {
    RootView()
}
