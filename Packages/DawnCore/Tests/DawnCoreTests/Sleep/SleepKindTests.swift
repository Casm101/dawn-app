import Foundation
import Testing
@testable import DawnCore

struct SleepKindTests {
    private typealias F = SleepFixture

    private func kind(_ day: Int, _ from: String, _ to: String) -> SleepKind {
        let sample = F.sample(day, from, to, .unspecified)
        return SleepKind(start: sample.start, end: sample.end, calendar: F.calendar)
    }

    @Test func aShortAfternoonSessionIsANap() {
        #expect(kind(1, "14:00", "14:40") == .nap)
    }

    @Test func aFullNightIsANight() {
        #expect(kind(0, "23:00", "07:00") == .night)
    }

    @Test func aShortSessionBeforeDawnBelongsToTheNight() {
        #expect(kind(1, "02:00", "04:00") == .night)
    }

    @Test func aDaytimeSessionOfTwoAndAHalfHoursOrMoreIsNotANap() {
        #expect(kind(1, "12:00", "14:30") == .night)
    }

    @Test func aShortSessionEndingInTheEveningIsNotANap() {
        #expect(kind(1, "17:00", "18:30") == .night)
    }

    @Test func groupedSessionsCarryTheirKind() {
        let sessions = SessionGrouper.sessions(
            from: [F.sample(0, "23:00", "07:00", .core), F.sample(1, "14:00", "14:40", .core)],
            calendar: F.calendar
        )
        #expect(sessions.map(\.kind) == [.night, .nap])
    }
}
