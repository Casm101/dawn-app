import Foundation
import Testing
@testable import DawnCore

struct ProgressNightsTests {
    private typealias D = DebtFixture
    /// Midday today in the debt fixture, so tonight is today's evening.
    private let now = D.today.addingTimeInterval(12 * 3600)

    private func makeSlots(_ sessions: [SleepSession]) -> [NightSlot] {
        ProgressNights.slots(from: sessions, now: now, calendar: D.calendar)
    }

    @Test func fourteenEveningsEndWithTonightOldestFirst() {
        let slots = makeSlots([])
        #expect(slots.count == 14)
        #expect(slots.last?.evening == D.today)
        #expect(slots.last?.isTonight == true)
        #expect(slots.first?.evening == D.calendar.date(byAdding: .day, value: -13, to: D.today))
        #expect(slots.filter(\.isTonight).count == 1)
    }

    @Test func aNightGoesToTheEveningItBegan() {
        let slots = makeSlots([D.night(0, hours: 8)])
        let lastNight = slots[12]
        #expect(lastNight.nights.count == 1)
        #expect(slots[13].nights.isEmpty)
    }

    @Test func aMissingNightLeavesItsSlotEmpty() {
        let slots = makeSlots([D.night(0, hours: 8), D.night(2, hours: 7)])
        #expect(slots[11].nights.isEmpty)
        #expect(slots.filter { !$0.nights.isEmpty }.count == 2)
    }

    @Test func napsAreNotNights() {
        #expect(makeSlots([D.nap(1, minutes: 40)]).allSatisfy { $0.nights.isEmpty })
    }

    @Test func pagesHoldSevenNightsOldestPageFirst() {
        let pages = ProgressNights.pages(makeSlots([]))
        #expect(pages.map(\.count) == [7, 7])
        #expect(pages[1].last?.isTonight == true)
    }

    @Test func theAxisRunsAcrossMidnightAndGrowsToFitLateNights() throws {
        let slot = makeSlots([D.night(0, hours: 9, wake: (10, 30))])
        let axis = NightAxis(slots: slot, calendar: D.calendar)
        #expect(axis.lower == 9)
        #expect(axis.upper == 23)
        let late = slot[12]
        let wake = try #require(late.nights.first).end
        #expect(abs(axis.position(wake, evening: late.evening, calendar: D.calendar) - (22.5 - 9) / 14) < 1e-9)
    }
}
