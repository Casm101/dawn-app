import DawnCore
import DawnUI
import SwiftUI

/// Whether tonight's wake window is armed, and what the last one did.
struct WakeStatusRow: View {
    @Environment(WakeController.self) private var wake

    var body: some View {
        VStack(alignment: .leading, spacing: DawnSpacing.xs) {
            if let armed = wake.arming.armed {
                Label(WakeCopy.armed, systemImage: "checkmark.circle.fill")
                    .font(DawnFont.title)
                    .foregroundStyle(DawnColor.accent)
                Text(WakeCopy.window(armed)).font(DawnFont.body).monospacedDigit()
            } else {
                Label(WakeCopy.nothingToArm, systemImage: "moon.zzz").font(DawnFont.title)
            }
            if let last = wake.log.latest {
                Text(WakeCopy.last(last)).font(DawnFont.caption).foregroundStyle(DawnColor.secondaryText)
            }
        }
        .accessibilityElement(children: .combine)
    }
}
