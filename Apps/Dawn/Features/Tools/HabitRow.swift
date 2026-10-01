import DawnCore
import DawnUI
import SwiftUI

/// One habit in Tools: whether it shows on the timeline, its time today, and, while it shows,
/// whether it sends a reminder.
struct HabitRow: View {
    let habit: Habit
    let time: HabitTime?
    @Environment(HabitStore.self) private var habits
    @Environment(HabitReminderScheduler.self) private var reminders

    var body: some View {
        VStack(alignment: .leading, spacing: DawnSpacing.sm) {
            Toggle(isOn: Binding(get: { habits.settings.isShown(habit) }, set: { habits.show(habit, $0) })) {
                Label {
                    VStack(alignment: .leading, spacing: DawnSpacing.xs) {
                        Text(HabitText.name(habit))
                        if let time {
                            Text(HabitText.time(time)).font(DawnFont.caption).foregroundStyle(DawnColor.secondaryText).monospacedDigit()
                        }
                    }
                } icon: {
                    Image(systemName: HabitText.symbol(habit))
                }
            }
            .accessibilityIdentifier("show-\(habit.rawValue)")
            if habits.settings.isShown(habit) {
                Toggle(String(localized: "tools.habit.remind", defaultValue: "Remind me"), isOn: Binding(
                    get: { habits.settings.reminds(habit) },
                    set: { on in
                        habits.remind(habit, on)
                        if on { Task { await reminders.requestPermission() } }
                    }
                ))
                .font(DawnFont.body)
                .accessibilityIdentifier("remind-\(habit.rawValue)")
            }
        }
    }
}
