import DawnCore
import DawnUI
import SwiftUI

/// Says the schedule stands on the usual times in Profile until Dawn has three recent nights.
struct LearningNote: View {
    let usual: UsualSleep

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: DawnSpacing.sm) {
            TagChip(text: PhaseText.learning, color: DawnColor.accent)
            Text(String(
                localized: "energy.learning",
                defaultValue: "Based on a usual bedtime of \(time(usual.bedtime)) and wake time of \(time(usual.wakeTime)), which you can change in Profile, until Dawn has \(Tuning.Energy.minimumNights) nights of sleep from the last week."
            ))
            .font(DawnFont.caption)
            .foregroundStyle(DawnColor.secondaryText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func time(_ clock: ClockTime) -> String {
        PhaseText.time(clock.date(on: Date(), calendar: .current))
    }
}
