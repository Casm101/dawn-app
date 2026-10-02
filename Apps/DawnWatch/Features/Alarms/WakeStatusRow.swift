import DawnCore
import DawnUI
import DawnWrist
import SwiftUI

/// Whether tonight's wake window is armed, and what the last one did.
struct WakeStatusRow: View {
    @Environment(WakeCoordinator.self) private var wake

    var body: some View {
        VStack(alignment: .leading, spacing: DawnSpacing.xs) {
            if let armed = wake.arming.armed {
                Label(WakeCopy.armed, systemImage: "checkmark.circle.fill")
                    .font(DawnFont.title)
                    .foregroundStyle(DawnColor.accent)
                Text(WakeCopy.window(armed)).font(DawnFont.body).monospacedDigit()
            } else if let plan = wake.plan {
                Label(WakeCopy.notArmed, systemImage: "exclamationmark.circle").font(DawnFont.title)
                Text(WakeCopy.window(plan)).font(DawnFont.body).monospacedDigit()
                Text(wake.armFailed ? WakeCopy.armFailed : WakeCopy.openToArm)
                    .font(DawnFont.caption).foregroundStyle(DawnColor.secondaryText)
            } else {
                Label(WakeCopy.nothingToArm, systemImage: "moon.zzz").font(DawnFont.title)
            }
            if let last = wake.log.latest {
                Text(WakeCopy.last(last)).font(DawnFont.caption).foregroundStyle(DawnColor.secondaryText)
                Text(WakeCopy.why(last)).font(DawnFont.caption).foregroundStyle(DawnColor.secondaryText)
            }
        }
        .accessibilityElement(children: .combine)
    }
}
