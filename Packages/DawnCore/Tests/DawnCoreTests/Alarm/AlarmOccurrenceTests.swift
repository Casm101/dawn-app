import Foundation
import Testing
@testable import DawnCore

struct AlarmOccurrenceTests {
    private typealias A = AlarmFixture

    private func next(_ alarm: AlarmSettings, after now: Date) -> Date? {
        AlarmOccurrence.next(alarm, after: now, calendar: A.calendar)
    }

    @Test func aWeekdayAlarmRingsLaterTheSameDay() {
        #expect(next(A.alarm(7, 0), after: A.at(0, "06:00")) == A.at(0, "07:00"))
    }

    @Test func aWeekdayAlarmThatHasRungTodayRingsTomorrow() {
        #expect(next(A.alarm(7, 0), after: A.at(0, "08:00")) == A.at(1, "07:00"))
    }

    @Test func aWeekendAlarmSkipsToSaturday() {
        #expect(next(A.alarm(9, 30, days: Weekday.weekend), after: A.at(1, "12:00")) == A.at(5, "09:30"))
    }

    @Test func aFridayAlarmJumpsTheWeekend() {
        #expect(next(A.alarm(7, 0), after: A.at(4, "07:00")) == A.at(7, "07:00"))
    }

    @Test func aOneOffAlarmRingsAtTheNextOccurrenceOfItsTime() {
        #expect(next(A.alarm(7, 0, days: []), after: A.at(2, "06:00")) == A.at(2, "07:00"))
        #expect(next(A.alarm(7, 0, days: []), after: A.at(2, "08:00")) == A.at(3, "07:00"))
    }

    private func problem(_ alarm: AlarmSettings, after now: Date) -> LeadTimeProblem? {
        AlarmOccurrence.leadTimeProblem(alarm, after: now, calendar: A.calendar)
    }

    @Test func aRepeatingAlarmEditedInsideTheLeadTimeNamesTheRingAfterIt() {
        #expect(problem(A.alarm(7, 0), after: A.at(0, "06:59")) == .nextRingTooClose(
            skipped: A.at(0, "07:00"), following: A.at(1, "07:00")
        ))
    }

    @Test func aOneOffAlarmInsideTheLeadTimeIsTooCloseToSet() {
        #expect(problem(A.alarm(7, 0, days: []), after: A.at(0, "06:59")) == .tooCloseToSet)
    }

    @Test func anEditJustOutsideTheLeadTimeIsFine() {
        #expect(problem(A.alarm(7, 0), after: A.at(0, "06:58", second: 29)) == nil)
    }

    @Test func theLeadTimeIsNinetySeconds() {
        #expect(problem(A.alarm(7, 0), after: A.at(0, "06:58", second: 31)) != nil)
        #expect(problem(A.alarm(7, 0), after: A.at(0, "06:58", second: 30)) == nil)
    }
}
