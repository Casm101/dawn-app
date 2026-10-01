import DawnCore
import DawnUI
import SwiftUI

/// A night in the list: its name, when it started and ended, how long it slept, and whether the
/// user corrected it.
struct NightRow: View {
    @Environment(SleepEditsStore.self) private var edits
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
                if edits.edits.correction(for: CalendarDay(slot.evening, calendar: .current)) != nil {
                    TagChip(text: EditText.edited, color: DawnColor.accent)
                }
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
