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
    @Environment(RatingStore.self) private var ratings
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
            Task { await reminders.refreshPermission() }
        }
        .onChange(of: habits.settings, initial: true) { scheduleReminders() }
        .onChange(of: sleep.sessions) { scheduleReminders() }
        .onChange(of: usual.usual) { scheduleReminders() }
        .onChange(of: ratings.ratings) { scheduleReminders() }
    }

    /// The coming week's reminders, from today's forecast and the usual days after it.
    private func scheduleReminders(force: Bool = false) {
        let now = Date(), sessions = sleep.sessions, rated = ratings.ratings
        let schedules = forecaster.forecast(sessions: sessions, usual: usual.usual, now: now).days
        let habitual = HabitualSleep(sessions: sessions, usual: usual.usual, now: now, calendar: .current)
        let days = HabitReminderPlan.days(from: schedules, habitual: habitual, now: now, calendar: .current)
        reminders.update(
            days: days, settings: habits.settings,
            isRated: { rated.score(for: NightRatings.night(endingAt: $0, sessions: sessions, calendar: .current)) != nil },
            now: now, force: force
        )
    }

    private func placeholder(_ title: String) -> some View {
        ContentUnavailableView(title, systemImage: "moon.zzz", description: Text("Coming in a later ticket."))
    }
}

#Preview {
    RootView()
}
