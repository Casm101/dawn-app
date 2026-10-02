import Foundation

/// Times on a fixed UTC calendar. Day 0 is Monday 28 September 2026.
enum DayFixture {
    static let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        return calendar
    }()

    static let monday = calendar.date(from: DateComponents(year: 2026, month: 9, day: 28))!

    /// A time on a fixture day, written as "07:00".
    static func at(_ day: Int, _ time: String) -> Date {
        let parts = time.split(separator: ":").compactMap { Int($0) }
        let start = calendar.date(byAdding: .day, value: day, to: monday)!
        return calendar.date(bySettingHour: parts[0], minute: parts[1], second: 0, of: start)!
    }
}
