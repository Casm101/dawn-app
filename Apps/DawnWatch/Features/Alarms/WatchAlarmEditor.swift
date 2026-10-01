import DawnCore
import DawnUI
import SwiftUI

/// Changes one alarm's time, wake window, days and switch; the phone follows.
struct WatchAlarmEditor: View {
    @Environment(WatchAlarmStore.self) private var alarms
    @Environment(\.dismiss) private var dismiss
    @State private var draft: AlarmSettings
    /// Refreshed every few seconds so the lead-time note follows the clock.
    @State private var now = Date()
    /// The settings when the editor opened, so saving keeps changes that arrived from the phone since.
    private let original: AlarmSettings
    private let id: UUID

    init(id: UUID, settings: AlarmSettings) {
        self.id = id
        original = settings
        _draft = State(initialValue: settings)
    }

    var body: some View {
        Form {
            Section {
                DatePicker(
                    String(localized: "watch.edit.time", defaultValue: "Time"), selection: time, displayedComponents: .hourAndMinute
                )
            } footer: {
                if let problem { WatchLeadTimeNote(problem: problem) }
            }
            Stepper(value: $draft.windowMinutes, in: Tuning.Alarm.windowMinutes, step: 5) {
                Text(String(localized: "watch.edit.window", defaultValue: "\(draft.windowMinutes) min window"))
            }
            Toggle(String(localized: "watch.edit.on", defaultValue: "On"), isOn: $draft.isEnabled)
            Section(String(localized: "watch.edit.days", defaultValue: "Days")) {
                ForEach(Weekday.allCases.sorted { RepeatPattern.mondayFirst($0) < RepeatPattern.mondayFirst($1) }, id: \.self) { day in
                    Toggle(Calendar.current.weekdaySymbols[day.rawValue - 1], isOn: Binding(
                        get: { draft.repeatDays.contains(day) },
                        set: { if $0 { draft.repeatDays.insert(day) } else { draft.repeatDays.remove(day) } }
                    ))
                }
            }
            Button(String(localized: "watch.edit.delete", defaultValue: "Delete"), role: .destructive) {
                alarms.delete(id)
                dismiss()
            }
        }
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button(String(localized: "watch.edit.save", defaultValue: "Save")) {
                    alarms.save(draft.rebased(from: original, onto: alarms.document.alarm(id)?.settings), id: id)
                    dismiss()
                }
                .disabled(problem == .tooCloseToSet)
            }
        }
        .task {
            while !Task.isCancelled {
                now = Date()
                try? await Task.sleep(for: .seconds(5))
            }
        }
    }

    private var problem: LeadTimeProblem? {
        draft.isEnabled ? AlarmOccurrence.leadTimeProblem(draft, after: now, calendar: .current) : nil
    }

    private var time: Binding<Date> {
        Binding(
            get: { draft.time.date(on: Date(), calendar: .current) },
            set: { draft.time = ClockTime($0, calendar: .current) }
        )
    }
}
