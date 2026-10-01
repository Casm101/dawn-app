import Foundation
import Testing
@testable import DawnCore

struct ClockTimeDateTests {
    @Test func aTimeLandsOnTheGivenDayAndReadsBack() {
        let calendar = SleepFixture.calendar
        let time = ClockTime(hour: 6, minute: 45)!
        let date = time.date(on: SleepFixture.monday, calendar: calendar)
        #expect(date == SleepFixture.at(0, "06:45"))
        #expect(ClockTime(date, calendar: calendar) == time)
    }
}
