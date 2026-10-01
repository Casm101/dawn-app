import Foundation
@testable import DawnCore

/// Alarms and moments on the sleep fixture's UTC calendar; day 0 is Monday 28 September 2026.
enum AlarmFixture {
    static let calendar = SleepFixture.calendar

    static func alarm(_ hour: Int, _ minute: Int, days: Set<Weekday> = Weekday.weekdays) -> AlarmDefinition {
        AlarmDefinition(time: ClockTime(hour: hour, minute: minute)!, repeatDays: days)
    }

    static func at(_ day: Int, _ time: String, second: Int = 0) -> Date {
        SleepFixture.at(day, time).addingTimeInterval(TimeInterval(second))
    }
}
