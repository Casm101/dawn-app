import Foundation
import Testing
@testable import DawnCore

struct NightLabelTests {
    private typealias D = DebtFixture

    private func label(_ daysBack: Int, at hour: Int) -> NightLabel {
        let evening = D.calendar.date(byAdding: .day, value: -daysBack, to: D.today)!
        return NightLabel(evening: evening, now: D.today.addingTimeInterval(Double(hour) * 3600), calendar: D.calendar)
    }

    @Test func todaysEveningIsTonight() {
        #expect(label(0, at: 21) == .tonight)
    }

    @Test func yesterdaysEveningIsLastNightEvenInTheEarlyMorning() {
        #expect(label(1, at: 6) == .lastNight)
        #expect(label(1, at: 14) == .lastNight)
    }

    @Test func eveningsThisWeekAreNamedByTheirDay() {
        #expect(label(3, at: 9) == .evening(D.calendar.date(byAdding: .day, value: -3, to: D.today)!))
        #expect(label(6, at: 9) == .evening(D.calendar.date(byAdding: .day, value: -6, to: D.today)!))
    }

    @Test func eveningsAWeekOrMoreAgoCarryTheirDate() {
        #expect(label(7, at: 9) == .earlier(D.calendar.date(byAdding: .day, value: -7, to: D.today)!))
    }

    @Test func afterMidnightTheNightStillToComeIsTonightAndTheOneBeforeIsLastNight() {
        #expect(label(1, at: 1) == .tonight)
        #expect(label(2, at: 1) == .lastNight)
        #expect(label(0, at: 1) != .tonight)
    }
}
