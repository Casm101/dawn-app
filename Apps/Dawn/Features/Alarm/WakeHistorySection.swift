import DawnCore
import DawnUI
import SwiftUI

/// What the Watch's wake window did on recent mornings for this alarm.
struct WakeHistorySection: View {
    let outcomes: [WakeOutcome]

    var body: some View {
        if !outcomes.isEmpty {
            Section(String(localized: "alarm.history.title", defaultValue: "Recent wakes")) {
                ForEach(outcomes) { outcome in
                    VStack(alignment: .leading, spacing: DawnSpacing.xs) {
                        Text(WakeText.headline(outcome)).font(DawnFont.body)
                        Text(WakeText.detail(outcome))
                            .font(DawnFont.caption)
                            .foregroundStyle(DawnColor.secondaryText)
                    }
                    .accessibilityElement(children: .combine)
                }
            }
        }
    }
}
