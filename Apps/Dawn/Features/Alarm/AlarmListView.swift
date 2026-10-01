import DawnAlarmKit
import DawnCore
import DawnUI
import SwiftUI

/// Every alarm, each with its switch; swipe to delete, tap to edit, + to add.
struct AlarmListView: View {
    @Environment(AlarmLibrary.self) private var library
    @Environment(\.dismiss) private var dismiss
    @State private var creating = false

    var body: some View {
        NavigationStack {
            List {
                if library.permission == .denied {
                    AlarmPermissionNote()
                }
                if let problem = library.problem {
                    AlarmProblemBanner(problem: problem)
                }
                ForEach(library.alarms) { alarm in
                    NavigationLink(value: alarm) { AlarmRow(alarm: alarm) }
                }
                .onDelete { offsets in
                    let ids = offsets.map { library.alarms[$0].id }
                    Task { for id in ids { await library.delete(id) } }
                }
            }
            .overlay {
                if library.alarms.isEmpty {
                    ContentUnavailableView(
                        String(localized: "alarms.empty.title", defaultValue: "No alarms"),
                        systemImage: "alarm",
                        description: Text(String(localized: "alarms.empty.body", defaultValue: "Tap + to set one."))
                    )
                }
            }
            .navigationTitle(String(localized: "alarms.title", defaultValue: "Alarms"))
            .navigationDestination(for: AlarmDefinition.self) {
                AlarmEditorView(id: $0.id, settings: $0.settings, isNew: false)
            }
            .navigationDestination(isPresented: $creating) {
                AlarmEditorView(id: UUID(), settings: AlarmSettings(time: ClockTime(hour: 7, minute: 0)!), isNew: true)
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "alarms.done", defaultValue: "Done")) { dismiss() }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button(String(localized: "alarms.add", defaultValue: "Add alarm"), systemImage: "plus") { creating = true }
                }
            }
        }
    }
}
