import DawnCore
import DawnUI
import SwiftUI

/// One stretch of sleep on the timeline, from when it began to when it ended.
struct SleepSegmentCard: View {
    let segment: SleepSegment
    let window: TimelineWindow
    let height: CGFloat

    var body: some View {
        let top = window.position(segment.start) * height
        let cardHeight = max(DawnSize.minimumBar, (window.position(segment.end) - window.position(segment.start)) * height)
        VStack(alignment: .leading) {
            if cardHeight >= DawnSize.cardWithTimes {
                Label(time(segment.start), systemImage: "moon.zzz")
                Spacer(minLength: 0)
                Label(time(segment.end), systemImage: "sun.horizon")
            }
        }
        .font(DawnFont.caption)
        .foregroundStyle(DawnColor.onAccent)
        .padding(.horizontal, DawnSpacing.sm)
        .padding(.vertical, cardHeight >= DawnSize.cardWithTimes ? DawnSpacing.xs : 0)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: cardHeight)
        .background(DawnColor.accent, in: RoundedRectangle(cornerRadius: DawnRadius.chip, style: .continuous))
        .offset(y: top)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(String(localized: "energy.segment", defaultValue: "Asleep \(time(segment.start)) to \(time(segment.end))"))
    }

    private func time(_ date: Date) -> String {
        date.formatted(date: .omitted, time: .shortened)
    }
}
