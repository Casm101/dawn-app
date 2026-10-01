import DawnCore
import DawnUI
import SwiftUI

/// One phase: its name, "until" its end when it is under way or its span when it is to come, and
/// its change since yesterday.
struct PhaseCardView: View {
    let card: PhaseCard

    var body: some View {
        VStack(alignment: .leading, spacing: DawnSpacing.xs) {
            Text(PhaseText.name(card.span.phase))
                .font(DawnFont.body.weight(.semibold))
                .foregroundStyle(DawnColor.phase(card.span.phase))
            Text(card.isCurrent ? PhaseText.until(card.span) : PhaseText.span(card.span))
                .font(DawnFont.body)
                .monospacedDigit()
            if let change = card.change {
                Text(PhaseText.change(change))
                    .font(DawnFont.caption)
                    .foregroundStyle(DawnColor.secondaryText)
            }
        }
        .frame(width: DawnSize.phaseCard, alignment: .leading)
        .padding(DawnSpacing.md)
        .background(DawnColor.phaseTint(card.span.phase), in: RoundedRectangle(cornerRadius: DawnRadius.card, style: .continuous))
        .accessibilityElement(children: .combine)
    }
}
