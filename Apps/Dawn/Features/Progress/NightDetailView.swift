import DawnCore
import DawnUI
import SwiftUI

/// One night opened up: its sleep segments in order with the awake gaps between, the stage
/// breakdown when there is one, and where the data came from.
struct NightDetailView: View {
    let slot: NightSlot

    var body: some View {
        List {
            Section {
                MetricView(
                    value: DurationFormat.short(slot.asleep),
                    caption: String(localized: "night.detail.asleep", defaultValue: "Asleep")
                )
                if let totals = slot.stageTotals {
                    StageTotalsRow(totals: totals)
                }
                ForEach(sources, id: \.self) { source in
                    Text(String(localized: "home.lastNight.source", defaultValue: "\(source) via Apple Health"))
                        .font(DawnFont.caption)
                        .foregroundStyle(DawnColor.secondaryText)
                }
            }
            Section(String(localized: "night.detail.segments", defaultValue: "Segments")) {
                ForEach(slot.timeline) { entry in
                    NightTimelineRow(entry: entry)
                }
            }
        }
        .navigationTitle(NightText.label(for: slot))
    }

    private var sources: [String] {
        slot.nights.map(\.source).reduce(into: []) { if !$0.contains($1) { $0.append($1) } }
    }
}
