import DawnCore
import DawnUI
import SwiftUI

/// A segment or an awake gap in a night's timeline.
struct NightTimelineRow: View {
    let entry: NightTimelineEntry

    var body: some View {
        HStack {
            Image(systemName: entry.isAwake ? "eye" : "moon.zzz")
                .foregroundStyle(entry.isAwake ? DawnColor.awake : DawnColor.accent)
            VStack(alignment: .leading, spacing: DawnSpacing.xs) {
                Text(entry.isAwake
                    ? String(localized: "night.detail.awake", defaultValue: "Awake")
                    : String(localized: "night.detail.segment", defaultValue: "Asleep"))
                    .font(DawnFont.body)
                Text(NightText.range(entry.start, entry.end))
                    .font(DawnFont.caption)
                    .foregroundStyle(DawnColor.secondaryText)
            }
            Spacer()
            Text(DurationFormat.short(entry.duration))
                .font(DawnFont.body)
                .monospacedDigit()
        }
        .accessibilityElement(children: .combine)
    }
}
