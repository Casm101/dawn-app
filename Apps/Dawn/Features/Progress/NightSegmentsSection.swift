import DawnCore
import DawnUI
import SwiftUI

/// The night's segments and awake gaps in order. Within `Tuning.Edits.days` a segment can be swiped
/// away, so long as another one is left.
struct NightSegmentsSection: View {
    let slot: NightSlot
    let delete: (Date) -> Void

    var body: some View {
        Section(String(localized: "night.detail.segments", defaultValue: "Segments")) {
            ForEach(slot.timeline) { entry in
                NightTimelineRow(entry: entry)
                    .swipeActions {
                        if !entry.isAwake, slot.segments.count > 1, SleepEdits.isEditable(day: slot.evening, now: Date(), calendar: .current) {
                            Button(EditText.delete, role: .destructive) { delete(entry.start) }
                        }
                    }
            }
        }
    }
}
