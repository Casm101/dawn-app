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

    @Test func olderEveningsAreNamedByTheirDay() {
        #expect(label(3, at: 9) == .evening(D.calendar.date(byAdding: .day, value: -3, to: D.today)!))
    }
}
