import DawnCore
import DawnUI
import SwiftUI

/// One night: its weekday on top, its sleep segments as bars with the gaps showing, and its length
/// underneath. Tonight, before any sleep, is a dashed outline; a missing night is an empty column.
struct NightColumn: View {
    let slot: NightSlot
    let axis: NightAxis

    var body: some View {
        VStack(spacing: DawnSpacing.xs) {
            Text(slot.evening.formatted(.dateTime.weekday(.abbreviated)))
                .font(DawnFont.caption)
                .foregroundStyle(DawnColor.secondaryText)
            GeometryReader { proxy in
                ZStack(alignment: .top) {
                    ForEach(slot.segments) { segment in
                        bar(from: position(segment.start), to: position(segment.end), in: proxy.size)
                            .fill(DawnColor.accent)
                    }
                    if slot.isTonight && slot.nights.isEmpty {
                        bar(from: placeholder.lowerBound, to: placeholder.upperBound, in: proxy.size)
                            .stroke(DawnColor.secondaryText, style: DawnStroke.placeholder)
                    }
                }
                .frame(width: proxy.size.width, height: proxy.size.height, alignment: .top)
            }
            .frame(height: DawnSize.chartHeight)
            Text(duration)
                .font(DawnFont.caption)
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(NightText.label(for: slot))
        .accessibilityValue(duration)
    }

    private var duration: String {
        if !slot.nights.isEmpty { return DurationFormat.short(slot.asleep) }
        return slot.isTonight ? String(localized: "progress.tonight.empty", defaultValue: "--h --m") : ""
    }

    private var placeholder: ClosedRange<Double> {
        let range = Tuning.Progress.placeholder
        return ((range.lowerBound - axis.lower) / axis.span)...((range.upperBound - axis.lower) / axis.span)
    }

    private func position(_ date: Date) -> Double {
        axis.position(date, evening: slot.evening, calendar: .current)
    }

    private func bar(from top: Double, to bottom: Double, in size: CGSize) -> some Shape {
        let height = max(DawnSize.minimumBar, (bottom - top) * size.height)
        let width = size.width * DawnSize.barFill
        return RoundedRectangle(cornerRadius: DawnRadius.chip, style: .continuous)
            .path(in: CGRect(x: (size.width - width) / 2, y: top * size.height, width: width, height: height))
    }
}
