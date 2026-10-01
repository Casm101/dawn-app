import DawnAlarmKit
import DawnCore
import DawnUI
import SwiftUI

/// Tells the user what happened to the alarm they just changed, when it was not simply saved.
struct AlarmProblemBanner: View {
    let problem: AlarmProblem

    var body: some View {
        Label(message, systemImage: "exclamationmark.triangle")
            .font(DawnFont.body)
            .foregroundStyle(DawnColor.warning)
    }

    private var message: String {
        switch problem {
        case .couldNotSchedule(let time):
            String(
                localized: "alarms.problem.notScheduled",
                defaultValue: "The system did not accept the \(AlarmText.time(time)) alarm, so it is off. Try switching it on again."
            )
        case .tooSoonToSet(let time):
            String(
                localized: "alarms.problem.tooSoon",
                defaultValue: "The \(AlarmText.time(time)) alarm is too close to its time to set. Choose a later time."
            )
        case .mayMissNextRing(let skipped, let following):
            String(
                localized: "alarms.problem.mayMiss",
                defaultValue: "It may not ring at \(skipped.formatted(.dateTime.hour().minute())), which is too soon. From \(following.formatted(.dateTime.weekday(.wide).hour().minute())) it rings as set."
            )
        case .couldNotLoad:
            String(
                localized: "alarms.problem.notLoaded",
                defaultValue: "Dawn could not read your saved alarms, so it will not change them. Alarms already set with the system still ring."
            )
        case .couldNotCheck:
            String(
                localized: "alarms.problem.notChecked",
                defaultValue: "Dawn could not check your alarms against the system this time, so it left them as they are."
            )
        case .couldNotSave:
            String(localized: "alarms.problem.notSaved", defaultValue: "Dawn could not save your alarms on this iPhone.")
        }
    }
}
