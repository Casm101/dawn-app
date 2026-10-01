import Testing
@testable import DawnCore

struct RepeatPatternTests {
    @Test func namedPatternsAreRecognised() {
        #expect(RepeatPattern([]) == .once)
        #expect(RepeatPattern(Set(Weekday.allCases)) == .everyDay)
        #expect(RepeatPattern(Weekday.weekdays) == .weekdays)
        #expect(RepeatPattern(Weekday.weekend) == .weekend)
    }

    @Test func otherDaysAreListedMondayFirst() {
        #expect(RepeatPattern([.sunday, .wednesday, .monday]) == .days([.monday, .wednesday, .sunday]))
    }
}
