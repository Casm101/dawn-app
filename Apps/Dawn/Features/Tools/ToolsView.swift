import DawnCore
import DawnUI
import SwiftUI

/// The Tools tab: each habit's switch for the timeline and for a reminder at its time.
struct ToolsView: View {
    @Environment(HabitStore.self) private var habits
    @Environment(HabitReminderScheduler.self) private var reminders
    @Environment(SleepStore.self) private var sleep
    @Environment(UsualSleepStore.self) private var usual
    @Environment(EnergyForecaster.self) private var forecaster
    @Environment(\.openURL) private var openURL

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(Habit.allCases, id: \.self) { habit in
                        HabitRow(habit: habit, time: times[habit])
                    }
                } header: {
                    Text(String(localized: "tools.habits.title", defaultValue: "Habits"))
                } footer: {
                    VStack(alignment: .leading, spacing: DawnSpacing.sm) {
                        Text(String(
                            localized: "tools.habits.footer",
                            defaultValue: "Times follow today's energy schedule. Reminders never come between your usual bedtime and wake time."
                        ))
                        if reminders.isDenied {
                            Text(String(localized: "tools.habits.denied", defaultValue: "Notifications are off for Dawn, so reminders cannot come."))
                                .foregroundStyle(DawnColor.warning)
                            Button(String(localized: "tools.habits.settings", defaultValue: "Open Settings")) {
                                if let url = URL(string: UIApplication.openNotificationSettingsURLString) { openURL(url) }
                            }
                        }
                        if habits.isUnsaved {
                            Text(String(localized: "tools.habits.notSaved", defaultValue: "Dawn could not save these switches on this iPhone, so changes last until Dawn closes."))
                                .foregroundStyle(DawnColor.warning)
                        }
                    }
                }
            }
            .navigationTitle(String(localized: "tools.title", defaultValue: "Tools"))
            .task { await reminders.refreshPermission() }
        }
    }

    /// Today's time for each habit, as the timeline shows them.
    private var times: [Habit: HabitTime] {
        let forecast = forecaster.forecast(sessions: sleep.sessions, usual: usual.usual, now: Date())
        let today = HabitTime.times(for: forecast.days).filter { $0.wake == forecast.today.wake }
        return Dictionary(uniqueKeysWithValues: today.map { ($0.habit, $0) })
    }
}
