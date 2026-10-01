import DawnUI
import SwiftUI

/// Says the schedule stands on the usual times from Profile until Dawn has three recent nights.
struct LearningNote: View {
    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: DawnSpacing.sm) {
            TagChip(text: PhaseText.learning, color: DawnColor.accent)
            Text(String(
                localized: "energy.learning",
                defaultValue: "Based on your usual bedtime and wake time until Dawn has three nights of sleep."
            ))
            .font(DawnFont.caption)
            .foregroundStyle(DawnColor.secondaryText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
