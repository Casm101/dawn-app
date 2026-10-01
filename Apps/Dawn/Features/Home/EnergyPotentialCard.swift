import DawnCore
import DawnUI
import SwiftUI

/// Today's energy potential, which sleep debt alone sets.
struct EnergyPotentialCard: View {
    let percent: Int

    var body: some View {
        DawnCard {
            Text(String(localized: "home.potential.title", defaultValue: "Energy potential"))
                .font(DawnFont.title)
            MetricView(
                value: (Double(percent) / 100).formatted(.percent.precision(.fractionLength(0))),
                caption: String(localized: "home.potential.caption", defaultValue: "How much of your energy your sleep debt leaves you today")
            )
        }
    }
}
