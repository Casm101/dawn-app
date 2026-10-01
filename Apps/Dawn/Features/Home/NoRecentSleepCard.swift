import DawnUI
import SwiftUI
import UIKit

/// Shown when Health has no sleep from the past two days, whether none was recorded or reading
/// it was turned off. Health does not say which, so the card covers both.
struct NoRecentSleepCard: View {
    @Environment(\.openURL) private var openURL

    var body: some View {
        DawnCard {
            Text(String(localized: "home.empty.title", defaultValue: "No sleep in the last two days"))
                .font(DawnFont.title)
            Text(String(
                localized: "home.empty.body",
                defaultValue: "Apple Health has no sleep for Dawn from the past two days. If you turned off sleep access for Dawn, you can turn it back on in Settings."
            ))
            .font(DawnFont.body)
            .foregroundStyle(DawnColor.secondaryText)
            Button {
                if let url = URL(string: UIApplication.openSettingsURLString) { openURL(url) }
            } label: {
                Text(String(localized: "home.empty.settings", defaultValue: "Open Settings"))
            }
            .buttonStyle(.bordered)
            .padding(.top, DawnSpacing.sm)
        }
    }
}
