import DawnCore
import DawnUI
import SwiftUI

/// A night's time asleep, its stages and where its data came from, marked when the user corrected it.
struct NightSummarySection: View {
    let slot: NightSlot
    let isEdited: Bool

    var body: some View {
        Section {
            HStack(alignment: .firstTextBaseline) {
                MetricView(
                    value: DurationFormat.short(slot.asleep),
                    caption: String(localized: "night.detail.asleep", defaultValue: "Asleep")
                )
                Spacer()
                if isEdited { TagChip(text: EditText.edited, color: DawnColor.accent) }
            }
            if let totals = slot.stageTotals {
                StageTotalsRow(totals: totals)
            }
            ForEach(sources, id: \.self) { source in
                Text(String(localized: "home.lastNight.source", defaultValue: "\(source) via Apple Health"))
                    .font(DawnFont.caption)
                    .foregroundStyle(DawnColor.secondaryText)
            }
        }
    }

    private var sources: [String] {
        slot.nights.map(\.source).reduce(into: []) { if !$0.contains($1) { $0.append($1) } }
    }
}
