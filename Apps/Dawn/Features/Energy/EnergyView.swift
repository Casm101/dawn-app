import DawnCore
import DawnUI
import SwiftUI

/// The Energy tab: a vertical 24-hour timeline from yesterday evening to this evening, opened with
/// now in the upper third of the screen. Later tickets draw the energy curve and habits on it.
struct EnergyView: View {
    @Environment(SleepStore.self) private var sleep

    var body: some View {
        NavigationStack {
            TimelineView(.periodic(from: .now, by: 30)) { context in
                let window = TimelineWindow(containing: context.date, calendar: .current)
                ScrollViewReader { proxy in
                    ScrollView {
                        EnergyTimeline(window: window, sessions: sleep.sessions, now: context.date)
                            .padding(.horizontal, DawnSpacing.lg)
                    }
                    .onAppear {
                        proxy.scrollTo(EnergyTimeline.nowAnchorID, anchor: UnitPoint(x: 0.5, y: Tuning.Timeline.nowAnchor))
                    }
                }
            }
            .navigationTitle(String(localized: "energy.title", defaultValue: "Energy"))
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
