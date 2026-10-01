import DawnUI
import SwiftUI

/// The line across the timeline at the current time, with the time on it.
struct NowMarker: View {
    let now: Date

    var body: some View {
        HStack(spacing: DawnSpacing.xs) {
            Text(now.formatted(date: .omitted, time: .shortened))
                .font(DawnFont.caption.weight(.semibold))
                .monospacedDigit()
                .foregroundStyle(DawnColor.onAccent)
                .padding(.horizontal, DawnSpacing.xs)
                .background(DawnColor.nowLine, in: Capsule())
            Rectangle()
                .fill(DawnColor.nowLine)
                .frame(height: DawnSize.nowLine)
        }
        .alignmentGuide(.top) { $0[VerticalAlignment.center] }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(String(localized: "energy.now", defaultValue: "Now, \(now.formatted(date: .omitted, time: .shortened))"))
    }
}
