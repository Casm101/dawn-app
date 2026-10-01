import DawnCore
import DawnUI
import SwiftUI

/// One phase of the day as a tinted band down the timeline, named at its top.
struct PhaseBand: View {
    let span: PhaseSpan
    let window: TimelineWindow
    let height: CGFloat

    var body: some View {
        let top = window.position(span.start) * height
        let bandHeight = (window.position(span.end) - window.position(span.start)) * height
        ViewThatFits(in: .vertical) {
            VStack(alignment: .leading, spacing: 0) {
                Text(PhaseText.name(span.phase)).font(DawnFont.caption.weight(.semibold))
                Text(PhaseText.span(span)).font(DawnFont.caption).foregroundStyle(DawnColor.secondaryText)
            }
            Text(PhaseText.name(span.phase)).font(DawnFont.caption.weight(.semibold))
            Color.clear
        }
        .padding(.horizontal, DawnSpacing.sm)
        .padding(.vertical, DawnSpacing.xs)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .frame(height: bandHeight, alignment: .topLeading)
        .background(DawnColor.phaseTint(span.phase))
        .overlay(alignment: .leading) { DawnColor.phase(span.phase).frame(width: DawnSize.minimumBar) }
        .clipped()
        .offset(y: top)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(PhaseText.name(span.phase)), \(PhaseText.span(span))")
    }
}
