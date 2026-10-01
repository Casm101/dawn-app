import DawnCore
import DawnUI
import SwiftUI

/// Sleep debt over the last 14 nights, its band, and how it moved since yesterday.
struct DebtCard: View {
    let summary: DebtSummary

    var body: some View {
        DawnCard {
            HStack {
                Text(String(localized: "home.debt.title", defaultValue: "Sleep debt"))
                    .font(DawnFont.title)
                Spacer()
                TagChip(text: DebtBandStyle.label(summary.band), color: DebtBandStyle.color(summary.band))
            }
            MetricView(value: hours, caption: change)
        }
    }

    private var hours: String {
        let value = summary.hours.formatted(.number.precision(.fractionLength(1)))
        return String(localized: "home.debt.hours", defaultValue: "\(value) h")
    }

    private var change: String {
        guard let change = summary.change else {
            return String(localized: "home.debt.new", defaultValue: "new")
        }
        let value = change.formatted(.number.precision(.fractionLength(1)).sign(strategy: .always()))
        return String(localized: "home.debt.change", defaultValue: "\(value) h since yesterday")
    }
}
