import DawnCore
import DawnUI
import SwiftUI

/// Last night: time asleep, time awake, the stage breakdown when there is one, and where it came from.
struct LastNightCard: View {
    let night: SleepSession

    var body: some View {
        DawnCard {
            Text(title)
                .font(DawnFont.title)
            MetricView(
                value: DurationFormat.short(night.asleep),
                caption: String(localized: "home.lastNight.asleep", defaultValue: "Asleep")
            )
            VStack(alignment: .leading, spacing: DawnSpacing.xs) {
                Text(String(localized: "home.lastNight.range", defaultValue: "\(time(night.start)) – \(time(night.end))"))
                Text(String(
                    localized: "home.lastNight.awake",
                    defaultValue: "Awake \(DurationFormat.short(night.awake)) during the night"
                ))
            }
            .font(DawnFont.body)
            .foregroundStyle(DawnColor.secondaryText)
            if let totals = night.stageTotals {
                StageTotalsRow(totals: totals)
                    .padding(.top, DawnSpacing.sm)
            }
            Text(String(localized: "home.lastNight.source", defaultValue: "\(night.source) via Apple Health"))
                .font(DawnFont.caption)
                .foregroundStyle(DawnColor.secondaryText)
                .padding(.top, DawnSpacing.sm)
        }
    }

    /// "Last night" when the night ended today, otherwise the evening it began, such as "Monday night".
    private var title: String {
        if Calendar.current.isDateInToday(night.end) {
            return String(localized: "home.lastNight.title", defaultValue: "Last night")
        }
        let evening = night.evening.formatted(.dateTime.weekday(.wide))
        return String(localized: "home.night.title", defaultValue: "\(evening) night")
    }

    private func time(_ date: Date) -> String {
        date.formatted(date: .omitted, time: .shortened)
    }
}
