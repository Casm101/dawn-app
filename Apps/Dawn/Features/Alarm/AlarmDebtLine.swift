import DawnCore
import DawnUI
import SwiftUI

/// Under the alarm: how the night before it changes sleep debt, red when the alarm comes before the
/// wake zone, and where the times come from while Dawn is still learning.
struct AlarmDebtLine: View {
    let preview: AlarmSleepPreview

    var body: some View {
        VStack(alignment: .leading, spacing: DawnSpacing.xs) {
            Text(AlarmPreviewText.debt(preview))
                .font(DawnFont.body.weight(.semibold))
                .foregroundStyle(preview.isEarly ? DawnColor.earlyAlarm : DawnColor.accent)
                .accessibilityIdentifier("alarm-debt-line")
            if preview.isLearning {
                Text(AlarmPreviewText.learning()).font(DawnFont.caption).foregroundStyle(DawnColor.secondaryText)
            }
        }
    }
}
