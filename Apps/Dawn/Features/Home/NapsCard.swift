import DawnCore
import DawnUI
import SwiftUI

/// Naps from the last two days, listed apart from last night.
struct NapsCard: View {
    let naps: [SleepSession]

    var body: some View {
        DawnCard {
            Text(String(localized: "home.naps.title", defaultValue: "Naps"))
                .font(DawnFont.title)
            ForEach(naps) { nap in
                HStack {
                    Text((nap.start..<nap.end).formatted(.interval.weekday().hour().minute()))
                        .foregroundStyle(DawnColor.secondaryText)
                    Spacer()
                    Text(DurationFormat.short(nap.asleep))
                        .monospacedDigit()
                }
                .font(DawnFont.body)
            }
        }
    }
}
