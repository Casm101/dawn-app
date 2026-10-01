import DawnCore
import DawnUI
import SwiftUI

/// Explains a lead-time problem: a repeating alarm may miss its next ring, a one-off cannot be set yet.
struct AlarmLeadTimeNote: View {
    let problem: LeadTimeProblem

    var body: some View {
        Label(message, systemImage: "clock.badge.exclamationmark")
            .font(DawnFont.caption)
            .foregroundStyle(DawnColor.warning)
    }

    private var message: String {
        switch problem {
        case .nextRingTooClose(let skipped, let following):
            let skippedTime = skipped.formatted(.dateTime.hour().minute())
            let next = following.formatted(.dateTime.weekday(.wide).hour().minute())
            return String(
                localized: "alarm.edit.nextRingTooClose",
                defaultValue: "It may not ring at \(skippedTime), which is too soon. From \(next) it rings as set."
            )
        case .tooCloseToSet:
            let notice = Duration.seconds(Tuning.Alarm.minimumLeadTime)
                .formatted(.units(allowed: [.minutes, .seconds], width: .wide))
            return String(
                localized: "alarm.edit.tooCloseToSet",
                defaultValue: "Too soon to set. An alarm needs at least \(notice) of notice."
            )
        }
    }
}
