import DawnCore
import DawnUI
import SwiftUI

/// The Energy tab: a vertical 24-hour timeline from yesterday evening to this evening with the day's
/// predicted energy and phases, opened with now in the upper third of the screen.
struct EnergyView: View {
    @Environment(SleepStore.self) private var sleep
    @Environment(UsualSleepStore.self) private var usual
    @Environment(EnergyForecaster.self) private var forecaster

    var body: some View {
        NavigationStack {
            TimelineView(.periodic(from: .now, by: 30)) { context in
                let window = TimelineWindow(containing: context.date, calendar: .current)
                let forecast = forecaster.forecast(sessions: sleep.sessions, usual: usual.usual, now: context.date)
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(spacing: 0) {
                            if forecast.today.isLearning {
                                LearningNote(usual: usual.usual)
                                    .padding(.horizontal, DawnSpacing.lg)
                            }
                            EnergyTimeline(
                                window: window, sessions: sleep.sessions,
                                schedules: forecast.days, now: context.date
                            )
                                .padding(.horizontal, DawnSpacing.lg)
                            // Room below the evening, so now can sit high on the screen late in the day too.
                            Color.clear.containerRelativeFrame(.vertical) { height, _ in height * Tuning.Timeline.scrollRoom }
                        }
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
