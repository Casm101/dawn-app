import DawnCore
import DawnHealth
import DawnUI
import SwiftUI

/// The Progress tab: two weeks of nights as a chart and a list, with debt and quality to follow.
struct SleepProgressView: View {
    @Environment(SleepStore.self) private var sleep
    @State private var segment = ProgressSegment.sleepTimes

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: DawnSpacing.lg) {
                    Picker(String(localized: "progress.segment", defaultValue: "View"), selection: $segment) {
                        ForEach(ProgressSegment.allCases, id: \.self) { Text($0.title).tag($0) }
                    }
                    .pickerStyle(.segmented)
                    switch segment {
                    case .sleepTimes:
                        sleepTimes
                    case .sleepDebt, .sleepQuality:
                        ComingLaterView()
                    }
                }
                .padding(DawnSpacing.lg)
            }
            .navigationTitle(String(localized: "progress.title", defaultValue: "Progress"))
            .navigationDestination(for: NightSlot.self) { NightDetailView(slot: $0) }
        }
    }

    /// The chart and list once Health has answered and been read; until then, what Home would say.
    @ViewBuilder private var sleepTimes: some View {
        switch sleep.access {
        case nil:
            ProgressView()
        case .notDetermined:
            HealthConnectCard { Task { await sleep.connect() } }
        case .unavailable:
            HealthUnavailableCard()
        case .granted, .denied:
            if sleep.hasLoaded {
                let slots = ProgressNights.slots(from: sleep.sessions, now: Date(), calendar: .current)
                SleepTimesChart(slots: slots)
                NightList(slots: slots)
            } else {
                ProgressView()
            }
        }
    }
}
