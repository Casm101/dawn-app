import DawnCore
import DawnUI
import SwiftUI

/// Two weeks of nights, a week to a page, opening on the latest week; swipe right for the week before.
struct SleepTimesChart: View {
    let slots: [NightSlot]
    @State private var page = Tuning.Progress.nights / Tuning.Progress.nightsPerPage - 1

    var body: some View {
        let pages = ProgressNights.pages(slots)
        DawnCard {
            Text(NightText.weekRange(pages.indices.contains(page) ? pages[page] : []))
                .font(DawnFont.title)
            TabView(selection: $page) {
                ForEach(pages.indices, id: \.self) { index in
                    WeekChart(slots: pages[index]).tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))
            .frame(height: DawnSize.chartHeight + DawnSize.chartFooter)
        }
    }
}
