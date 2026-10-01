import DawnCore
import DawnUI
import SwiftUI

/// One night opened up: its sleep segments in order with the awake gaps between, the stage
/// breakdown when there is one, and where the data came from. Within the last two weeks the night
/// can be corrected, and a corrected night can go back to Health's times.
struct NightDetailView: View {
    @Environment(SleepStore.self) private var sleep
    @Environment(SleepEditsStore.self) private var edits
    let evening: Date
    @State private var problem: NightEditProblem?

    var body: some View {
        let slot = ProgressNights.slots(from: sleep.sessions, now: Date(), calendar: .current).first { $0.evening == evening }
        List {
            if let slot {
                NightSummarySection(slot: slot, isEdited: isEdited)
                if SleepEdits.isEditable(day: evening, now: Date(), calendar: .current), !slot.segments.isEmpty {
                    Section {
                        NightEditorTrack(edit: edit(of: slot), commit: save, refuse: { problem = $0 })
                    } header: {
                        Text(EditText.editTitle)
                    } footer: {
                        Text(problem.map(EditText.problem) ?? EditText.hint)
                            .foregroundStyle(problem == nil ? DawnColor.secondaryText : DawnColor.warning)
                    }
                }
                NightSegmentsSection(slot: slot) { start in
                    var next = edit(of: slot)
                    guard let index = next.segments.firstIndex(where: { $0.start == start }) else { return }
                    next.delete(index)
                    save(next)
                }
            }
            if isEdited {
                Section {
                    Button(EditText.reset, role: .destructive) { edits.reset(evening) }
                }
            }
        }
        .navigationTitle(slot.map { NightText.label(for: $0) } ?? "")
    }

    private var isEdited: Bool { edits.edits.correction(for: evening) != nil }

    private func edit(of slot: NightSlot) -> NightEdit {
        NightEdit(segments: slot.segments.map { DateInterval(start: $0.start, end: $0.end) })
    }

    private func save(_ edit: NightEdit) {
        problem = nil
        edits.save(NightCorrection(evening: evening, segments: edit.segments))
    }
}
