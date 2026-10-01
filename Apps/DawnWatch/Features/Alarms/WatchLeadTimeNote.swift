import DawnCore
import DawnUI
import SwiftUI

/// Says when the alarm is too close to its time: a repeating one may miss this ring, a one-off cannot
/// be set yet.
struct WatchLeadTimeNote: View {
    let problem: LeadTimeProblem

    var body: some View {
        Text(message)
            .font(DawnFont.caption)
            .foregroundStyle(DawnColor.warning)
    }

    private var message: String {
        switch problem {
        case .nextRingTooClose(let skipped, _):
            let time = skipped.formatted(date: .omitted, time: .shortened)
            return String(localized: "watch.edit.nextRingTooClose", defaultValue: "Too soon for \(time). Rings as set after that.")
        case .tooCloseToSet:
            return String(localized: "watch.edit.tooCloseToSet", defaultValue: "Too soon to set.")
        }
    }
}
