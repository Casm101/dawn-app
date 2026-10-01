import Foundation
import Testing
@testable import DawnCore

struct TimelineWindowTests {
    private typealias F = SleepFixture

    @Test func beforeSixInTheEveningTheWindowRunsFromYesterdayEvening() {
        let window = TimelineWindow(containing: F.at(1, "12:00"), calendar: F.calendar)
        #expect(window.start == F.at(0, "18:00"))
        #expect(window.end == F.at(1, "18:00"))
    }

    @Test func afterSixInTheEveningTheWindowMovesOnSoNowStaysInside() {
        let window = TimelineWindow(containing: F.at(1, "19:30"), calendar: F.calendar)
        #expect(window.start == F.at(1, "18:00"))
        #expect(window.interval.contains(F.at(1, "19:30")))
    }

    @Test func positionsRunFromTopToBottom() {
        let window = TimelineWindow(containing: F.at(1, "12:00"), calendar: F.calendar)
        #expect(window.position(F.at(0, "18:00")) == 0)
        #expect(window.position(F.at(1, "06:00")) == 0.5)
        #expect(window.position(F.at(2, "06:00")) == 1)
    }

    @Test func theWindowHasAnHourLabelAtEachEnd() {
        let hours = TimelineWindow(containing: F.at(1, "12:00"), calendar: F.calendar).hours(calendar: F.calendar)
        #expect(hours.count == 25)
        #expect(hours.first == F.at(0, "18:00"))
    }

    @Test func segmentsAreClippedToTheWindow() throws {
        let window = TimelineWindow(containing: F.at(1, "12:00"), calendar: F.calendar)
        let sessions = SessionGrouper.sessions(from: [F.sample(0, "16:00", "17:30", .core), F.sample(0, "23:00", "07:00", .core)], calendar: F.calendar)
        let segments = window.segments(of: sessions)
        #expect(segments.count == 1)
        #expect(try #require(segments.first).start == F.at(0, "23:00"))
    }
}
