import Foundation
import Testing
@testable import DawnCore

struct NightSlotDetailTests {
    private typealias F = SleepFixture

    private func slot(_ samples: [SleepSample]) -> NightSlot {
        let nights = SessionGrouper.sessions(from: samples, calendar: F.calendar).filter { $0.kind == .night }
        return NightSlot(evening: F.at(0, "00:00"), nights: nights, isTonight: false)
    }

    @Test func theTimelineAlternatesSleepAndAwakeInOrder() {
        let timeline = slot([
            F.sample(0, "23:00", "01:00", .core), F.sample(1, "01:00", "01:20", .awake), F.sample(1, "01:20", "06:00", .deep),
        ]).timeline
        #expect(timeline.map(\.isAwake) == [false, true, false])
        #expect(timeline[1].start == F.at(1, "01:00"))
    }

    @Test func theAwakeTimeBetweenTwoSessionsOfOneEveningIsListed() {
        let timeline = slot([F.sample(0, "16:30", "18:30", .unspecified), F.sample(0, "23:00", "07:00", .core)]).timeline
        #expect(timeline.map(\.isAwake) == [false, true, false])
        #expect(timeline[1].duration == 4.5 * 3600)
    }

    @Test func stageTotalsCoverEverySessionOfTheEvening() throws {
        let totals = try #require(slot([F.sample(0, "16:30", "18:30", .unspecified), F.sample(0, "23:00", "07:00", .core)]).stageTotals)
        #expect(totals.core == 8 * 3600)
        #expect(totals.unspecified == 2 * 3600)
        #expect(totals.awake == 4.5 * 3600)
    }

    @Test func anEveningWithoutStagesHasNoTotals() {
        #expect(slot([F.sample(0, "23:00", "07:00", .unspecified)]).stageTotals == nil)
    }
}
