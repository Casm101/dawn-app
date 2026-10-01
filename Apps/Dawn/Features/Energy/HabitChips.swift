import DawnCore
import DawnUI
import SwiftUI

/// The shown habits of the days on the timeline, each at its time down the right-hand side. Once its
/// time has come, the rating prompt opens the rating sheet, and it shows the night's score once there is one.
struct HabitChips: View {
    let window: TimelineWindow
    let height: CGFloat
    let schedules: [EnergySchedule]
    let sessions: [SleepSession]
    let now: Date
    let rate: (CalendarDay) -> Void
    @Environment(HabitStore.self) private var habits
    @Environment(RatingStore.self) private var ratings

    var body: some View {
        ForEach(times) { time in
            chip(time)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .alignmentGuide(.top) { $0[VerticalAlignment.center] }
                .offset(y: window.position(time.start) * height)
        }
    }

    private var times: [HabitTime] {
        HabitTime.times(for: schedules).filter { time in
            habits.settings.isShown(time.habit) && window.interval.contains(time.start)
        }
    }

    @ViewBuilder
    private func chip(_ time: HabitTime) -> some View {
        let past = time.last <= now
        if time.habit == .rateLastNight, time.start <= now {
            let night = NightRatings.night(endingAt: time.wake, sessions: sessions, calendar: .current)
            let score = ratings.ratings.score(for: night)
            Button { rate(night) } label: {
                TimelineChip(symbol: HabitText.symbol(time.habit), text: score.map(HabitText.rated) ?? HabitText.name(time.habit), isPast: past)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(label(time, score: score))
        } else {
            TimelineChip(symbol: HabitText.symbol(time.habit), text: HabitText.name(time.habit), isPast: past)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(label(time, score: nil))
        }
    }

    private func label(_ time: HabitTime, score: Int?) -> String {
        let name = score.map(HabitText.rated) ?? HabitText.name(time.habit)
        return String(localized: "habit.chip.accessibility", defaultValue: "\(name), \(HabitText.time(time))")
    }
}
