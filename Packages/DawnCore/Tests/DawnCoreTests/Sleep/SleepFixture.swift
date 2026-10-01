import Foundation
@testable import DawnCore

/// Builds sleep samples on a fixed UTC calendar, so tests read like a sleep diary.
enum SleepFixture {
    static let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        return calendar
    }()

    /// Monday 28 September 2026, 00:00 UTC. Day 0 in every fixture.
    static let monday = calendar.date(from: DateComponents(year: 2026, month: 9, day: 28))!

    /// A time on a fixture day, written as "23:40".
    static func at(_ day: Int, _ time: String) -> Date {
        let parts = time.split(separator: ":").compactMap { Int($0) }
        let start = calendar.date(byAdding: .day, value: day, to: monday)!
        return calendar.date(bySettingHour: parts[0], minute: parts[1], second: 0, of: start)!
    }

    static func sample(
        _ day: Int, _ from: String, _ to: String, _ stage: SleepStage, source: String = "Apple Watch"
    ) -> SleepSample {
        let start = at(day, from)
        var end = at(day, to)
        if end <= start { end = calendar.date(byAdding: .day, value: 1, to: end)! }
        return SleepSample(start: start, end: end, stage: stage, source: source)
    }

    static func minutes(_ value: Double) -> TimeInterval { value * 60 }
}
