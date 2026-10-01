import DawnCore
import DawnUI
import SwiftUI

/// The night's segments and awake gaps in order; a segment within the last two weeks can be swiped away.
struct NightSegmentsSection: View {
    let slot: NightSlot
    let delete: (Date) -> Void

    var body: some View {
        Section(String(localized: "night.detail.segments", defaultValue: "Segments")) {
            ForEach(slot.timeline) { entry in
                NightTimelineRow(entry: entry)
                    .swipeActions {
                        if !entry.isAwake, SleepEdits.isEditable(day: slot.evening, now: Date(), calendar: .current) {
                            Button(EditText.delete, role: .destructive) { delete(entry.start) }
                        }
                    }
            }
        }
    }
}
