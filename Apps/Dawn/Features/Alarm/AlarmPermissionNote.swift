import DawnUI
import SwiftUI
import UIKit

/// Shown when the user has not let Dawn set system alarms, with the way back to Settings.
struct AlarmPermissionNote: View {
    @Environment(\.openURL) private var openURL

    var body: some View {
        VStack(alignment: .leading, spacing: DawnSpacing.sm) {
            Text(String(
                localized: "alarms.permission.body",
                defaultValue: "Alarms are turned off for Dawn, so none of these will ring. Turn them on in Settings."
            ))
            .font(DawnFont.body)
            Button(String(localized: "alarms.permission.settings", defaultValue: "Open Settings")) {
                if let url = URL(string: UIApplication.openSettingsURLString) { openURL(url) }
            }
        }
        .foregroundStyle(DawnColor.warning)
    }
}
