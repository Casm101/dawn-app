import DawnCore
import DawnUI
import SwiftUI

/// A night in the list: its name, when it started and ended, and how long it slept.
struct NightRow: View {
    let slot: NightSlot

    var body: some View {
        DawnCard {
            HStack {
                VStack(alignment: .leading, spacing: DawnSpacing.xs) {
                    Text(NightText.label(for: slot))
                        .font(DawnFont.body.weight(.semibold))
                    Text(NightText.bedToWake(slot))
                        .font(DawnFont.caption)
                        .foregroundStyle(DawnColor.secondaryText)
                }
                Spacer()
                Text(DurationFormat.short(slot.asleep))
                    .font(DawnFont.body)
                    .monospacedDigit()
                Image(systemName: "chevron.right")
                    .font(DawnFont.caption)
                    .foregroundStyle(DawnColor.secondaryText)
            }
        }
        .accessibilityElement(children: .combine)
    }
}
