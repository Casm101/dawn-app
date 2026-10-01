import Testing
@testable import DawnCore

struct ClockTimeTests {
    @Test func countsMinutesFromMidnight() {
        let time = ClockTime(hour: 6, minute: 30)
        #expect(time?.minutesSinceMidnight == 390)
    }

    @Test func rejectsOutOfRangeComponents() {
        #expect(ClockTime(hour: 24, minute: 0) == nil)
        #expect(ClockTime(hour: 6, minute: 60) == nil)
    }

    @Test func ordersByTimeOfDay() throws {
        let early = try #require(ClockTime(hour: 6, minute: 30))
        let late = try #require(ClockTime(hour: 7, minute: 0))
        #expect(early < late)
    }
}
