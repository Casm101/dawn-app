import DawnAlarmKit
import DawnCore
import DawnUI
import SwiftUI

/// Sets one alarm's time, days, sound and snooze. Saving replaces the system alarm.
struct AlarmEditorView: View {
    @Environment(AlarmLibrary.self) private var library
    @Environment(\.dismiss) private var dismiss
    @State private var draft: AlarmSettings
    /// The settings when the editor opened, so saving keeps changes that arrived from the Watch since.
    private let original: AlarmSettings
    @State private var preview = SoundPreview()
    /// Refreshed every few seconds so the lead-time note follows the clock.
    @State private var now = Date()
    @State private var isSaving = false
    private let id: UUID
    private let isNew: Bool

    init(id: UUID, settings: AlarmSettings, isNew: Bool) {
        _draft = State(initialValue: settings)
        original = settings
        self.id = id
        self.isNew = isNew
    }

    var body: some View {
        Form {
            Section {
                DatePicker(
                    String(localized: "alarm.edit.time", defaultValue: "Time"),
                    selection: time, displayedComponents: .hourAndMinute
                )
                .datePickerStyle(.wheel)
                .labelsHidden()
                .frame(maxWidth: .infinity)
            } footer: {
                if let problem { AlarmLeadTimeNote(problem: problem) }
            }
            Section(String(localized: "alarm.edit.repeat", defaultValue: "Repeat")) {
                WeekdayPicker(days: $draft.repeatDays)
                Text(AlarmText.days(draft.repeatDays))
                    .foregroundStyle(DawnColor.secondaryText)
            }
            Section(String(localized: "alarm.edit.sound", defaultValue: "Sound")) {
                SoundPicker(selection: $draft.sound, preview: preview)
            }
            Section {
                Stepper(value: $draft.snoozeMinutes, in: Tuning.Alarm.snoozeMinutes) {
                    Text(String(localized: "alarm.edit.snooze", defaultValue: "Snooze for \(draft.snoozeMinutes) min"))
                }
            }
            if !isNew {
                Section {
                    Button(String(localized: "alarm.edit.delete", defaultValue: "Delete alarm"), role: .destructive) {
                        Task { await library.delete(id); dismiss() }
                    }
                }
            }
        }
        .navigationTitle(isNew
            ? String(localized: "alarm.edit.newTitle", defaultValue: "New alarm")
            : String(localized: "alarm.edit.title", defaultValue: "Edit alarm"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button(String(localized: "alarm.edit.save", defaultValue: "Save")) {
                    var settings = draft.rebased(from: original, onto: library.document.alarm(id)?.settings)
                    settings.isEnabled = true
                    isSaving = true
                    Task { await library.save(settings, id: id); dismiss() }
                }
                .disabled(isSaving || problem == .tooCloseToSet)
            }
        }
        .onDisappear { preview.stop() }
        .task {
            while !Task.isCancelled {
                now = Date()
                try? await Task.sleep(for: .seconds(5))
            }
        }
    }

    private var problem: LeadTimeProblem? {
        AlarmOccurrence.leadTimeProblem(draft, after: now, calendar: .current)
    }

    private var time: Binding<Date> {
        Binding(
            get: { draft.time.date(on: Date(), calendar: .current) },
            set: { draft.time = ClockTime($0, calendar: .current) }
        )
    }
}
