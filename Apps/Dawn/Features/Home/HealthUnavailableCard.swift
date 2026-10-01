import DawnUI
import SwiftUI

/// Shown on a device without Apple Health.
struct HealthUnavailableCard: View {
    var body: some View {
        DawnCard {
            Text(String(localized: "home.unavailable.title", defaultValue: "Apple Health isn't available"))
                .font(DawnFont.title)
            Text(String(
                localized: "home.unavailable.body",
                defaultValue: "Dawn reads sleep from Apple Health, which this device doesn't have."
            ))
            .font(DawnFont.body)
            .foregroundStyle(DawnColor.secondaryText)
        }
    }
}
