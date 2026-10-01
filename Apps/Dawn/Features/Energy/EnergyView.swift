import DawnCore
import DawnUI
import SwiftUI

/// The Energy tab: a vertical 24-hour timeline from yesterday evening to this evening with the day's
/// predicted energy and phases, opened with now in the upper third of the screen.
struct EnergyView: View {
    @Environment(SleepStore.self) private var sleep
    @Environment(UsualSleepStore.self) private var usual
    @Environment(EnergyForecaster.self) private var forecaster
    @Environment(HabitRouter.self) private var router
    /// The night the rating sheet is open for.
    @State private var rating: CalendarDay?

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
                                schedules: forecast.days, now: context.date, rate: { rating = $0 }
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
        .sheet(isPresented: Binding(get: { rating != nil }, set: { if !$0 { rating = nil } })) {
            if let rating { RateNightSheet(night: rating) }
        }
        .onChange(of: router.isRating, initial: true) { _, asked in
            guard asked else { return }
            router.isRating = false
            rating = lastNight(now: Date())
        }
    }

    /// The night that ended at the latest waking so far, which a tapped rating reminder asks about.
    private func lastNight(now: Date) -> CalendarDay {
        let days = forecaster.forecast(sessions: sleep.sessions, usual: usual.usual, now: now).days
        let wake = days.filter { $0.wake <= now }.last?.wake ?? now
        return NightRatings.night(endingAt: wake, sessions: sleep.sessions, calendar: .current)
    }
}
