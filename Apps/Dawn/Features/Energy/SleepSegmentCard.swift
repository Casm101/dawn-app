import DawnCore
import DawnUI
import SwiftUI

/// One stretch of sleep on the timeline with when it began and ended: on two lines when the card
/// is tall enough, on one when it is short. An end cut off by the window edge shows no time.
struct SleepSegmentCard: View {
    let segment: TimelineSegment
    let window: TimelineWindow
    let height: CGFloat

    var body: some View {
        let top = window.position(segment.start) * height
        let cardHeight = max(DawnSize.minimumBar, (window.position(segment.end) - window.position(segment.start)) * height)
        ViewThatFits(in: .vertical) {
            VStack(alignment: .leading) {
                if !segment.startsBeforeWindow { Label(time(segment.start), systemImage: "moon.zzz") }
                Spacer(minLength: 0)
                if !segment.endsAfterWindow { Label(time(segment.end), systemImage: "sun.horizon") }
            }
            .padding(.vertical, DawnSpacing.xs)
            .frame(minHeight: DawnSize.cardWithTimes)
            Text(range)
                .frame(minHeight: DawnSize.cardWithRange)
            Color.clear
        }
        .font(DawnFont.caption)
        .foregroundStyle(DawnColor.onAccent)
        .padding(.horizontal, DawnSpacing.sm)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: cardHeight)
        .background(DawnColor.accent, in: RoundedRectangle(cornerRadius: DawnRadius.chip, style: .continuous))
        .clipShape(RoundedRectangle(cornerRadius: DawnRadius.chip, style: .continuous))
        .offset(y: top)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(String(localized: "energy.segment", defaultValue: "Asleep \(time(segment.start)) to \(time(segment.end))"))
    }

    private var range: String {
        String(localized: "energy.segment.range", defaultValue: "\(time(segment.start)) – \(time(segment.end))")
    }

    private func time(_ date: Date) -> String {
        date.formatted(date: .omitted, time: .shortened)
    }
}
