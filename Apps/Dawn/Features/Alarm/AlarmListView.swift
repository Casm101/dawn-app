import DawnAlarmKit
import DawnCore
import DawnUI
import SwiftUI

/// Every alarm, each with its switch; swipe to delete, tap to edit, + to add.
struct AlarmListView: View {
    @Environment(AlarmStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var creating = false

    var body: some View {
        NavigationStack {
            List {
                if store.permission == .denied {
                    AlarmPermissionNote()
                }
                if store.problem == .couldNotSchedule {
                    Label(
                        String(localized: "alarms.problem", defaultValue: "The system did not accept this alarm, so it will not ring. Try saving it again."),
                        systemImage: "exclamationmark.triangle"
                    )
                    .foregroundStyle(DawnColor.warning)
                }
                ForEach(store.alarms) { alarm in
                    NavigationLink(value: alarm) { AlarmRow(alarm: alarm) }
                }
                .onDelete { offsets in
                    let ids = offsets.map { store.alarms[$0].id }
                    Task { for id in ids { await store.delete(id) } }
                }
            }
            .overlay {
                if store.alarms.isEmpty {
                    ContentUnavailableView(
                        String(localized: "alarms.empty.title", defaultValue: "No alarms"),
                        systemImage: "alarm",
                        description: Text(String(localized: "alarms.empty.body", defaultValue: "Tap + to set one."))
                    )
                }
            }
            .navigationTitle(String(localized: "alarms.title", defaultValue: "Alarms"))
            .navigationDestination(for: AlarmDefinition.self) { AlarmEditorView(alarm: $0, isNew: false) }
            .navigationDestination(isPresented: $creating) {
                AlarmEditorView(alarm: AlarmDefinition(time: ClockTime(hour: 7, minute: 0)!), isNew: true)
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
