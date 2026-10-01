import DawnCore
import DawnUI
import SwiftUI

/// Asks for a nap's day, start and end, for any day in the last two weeks.
struct AddNapView: View {
    @Environment(SleepEditsStore.self) private var edits
    @Environment(SleepStore.self) private var sleep
    @Environment(\.dismiss) private var dismiss
    @State private var day = Date()
    /// The half hour that has just ended, the likeliest nap to be adding.
    @State private var start = NightEdit.snap(Date().addingTimeInterval(-Tuning.Edits.suggestedNap - Tuning.Edits.step))
    @State private var end = NightEdit.snap(Date().addingTimeInterval(-Tuning.Edits.step))
    @State private var problem: NightEditProblem?

    var body: some View {
        NavigationStack {
            Form {
                DatePicker(String(localized: "nap.day", defaultValue: "Day"), selection: $day, in: days, displayedComponents: .date)
                DatePicker(String(localized: "nap.start", defaultValue: "Fell asleep"), selection: $start, displayedComponents: .hourAndMinute)
                DatePicker(String(localized: "nap.end", defaultValue: "Woke"), selection: $end, displayedComponents: .hourAndMinute)
                if let problem {
                    Text(EditText.problem(problem)).foregroundStyle(DawnColor.warning)
                }
            }
            .navigationTitle(String(localized: "nap.title", defaultValue: "Add nap"))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "nap.cancel", defaultValue: "Cancel")) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "nap.save", defaultValue: "Save")) {
                        problem = edits.add(ManualNap(start: on(day, start), end: on(day, end)), existing: sleep.sessions)
                        if problem == nil { dismiss() }
                    }
                }
            }
        }
    }

    /// Today and the days before it that can still be edited.
    private var days: ClosedRange<Date> {
        let calendar = Calendar.current, today = Date()
        let earliest = calendar.date(byAdding: .day, value: -(Tuning.Edits.days - 1), to: calendar.startOfDay(for: today)) ?? today
        return earliest...today
    }

    /// The time of day of `time`, on the chosen day.
    private func on(_ day: Date, _ time: Date) -> Date {
        ClockTime(time, calendar: .current).date(on: day, calendar: .current)
    }
}
