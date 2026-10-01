import Foundation
import Testing
@testable import DawnCore

struct WeekdayTests {
    @Test func numbersMatchTheCalendar() {
        let monday = SleepFixture.monday
        #expect(SleepFixture.calendar.component(.weekday, from: monday) == Weekday.monday.rawValue)
    }

    @Test func weekdaysAndTheWeekendCoverTheWeekOnce() {
        #expect(Weekday.weekdays.union(Weekday.weekend) == Set(Weekday.allCases))
        #expect(Weekday.weekdays.isDisjoint(with: Weekday.weekend))
    }
}
