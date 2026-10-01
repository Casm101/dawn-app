import DawnCore
import DawnUI
import SwiftUI

/// Changes one alarm's time, wake window, days and switch; the phone follows.
struct WatchAlarmEditor: View {
    @Environment(WatchAlarmStore.self) private var alarms
    @Environment(\.dismiss) private var dismiss
    @State private var draft: AlarmSettings
    private let id: UUID

    init(id: UUID, settings: AlarmSettings) {
        self.id = id
        _draft = State(initialValue: settings)
    }

    var body: some View {
        Form {
            DatePicker(
                String(localized: "watch.edit.time", defaultValue: "Time"), selection: time, displayedComponents: .hourAndMinute
            )
            Stepper(value: $draft.windowMinutes, in: Tuning.Alarm.windowMinutes, step: 5) {
                Text(String(localized: "watch.edit.window", defaultValue: "\(draft.windowMinutes) min window"))
            }
            Toggle(String(localized: "watch.edit.on", defaultValue: "On"), isOn: $draft.isEnabled)
            Section(String(localized: "watch.edit.days", defaultValue: "Days")) {
                ForEach(Weekday.allCases, id: \.self) { day in
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
                    alarms.save(draft, id: id)
                    dismiss()
                }
            }
        }
    }

    private var time: Binding<Date> {
        Binding(
            get: { draft.time.date(on: Date(), calendar: .current) },
            set: { draft.time = ClockTime($0, calendar: .current) }
        )
    }
}
