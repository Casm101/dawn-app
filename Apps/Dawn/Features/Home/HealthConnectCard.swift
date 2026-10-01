import DawnUI
import SwiftUI

/// Explains why Dawn reads sleep from Apple Health, with the one button that asks.
struct HealthConnectCard: View {
    let connect: () -> Void

    var body: some View {
        DawnCard {
            Text(String(localized: "home.connect.title", defaultValue: "See last night from Apple Health"))
                .font(DawnFont.title)
            Text(String(
                localized: "home.connect.body",
                defaultValue: "Dawn reads your sleep from Apple Health to show how long you slept, how long you were awake, and your sleep stages when your Watch records them. Nothing leaves your iPhone."
            ))
            .font(DawnFont.body)
            .foregroundStyle(DawnColor.secondaryText)
            Button(action: connect) {
                Text(String(localized: "home.connect.button", defaultValue: "Connect Apple Health"))
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .padding(.top, DawnSpacing.sm)
        }
    }
}
