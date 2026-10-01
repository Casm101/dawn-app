import Foundation
import Testing
@testable import DawnCore

struct NightAxisClockTests {
    private let stockholm: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Europe/Stockholm")!
        return calendar
    }()

    private func date(_ day: Int, _ hour: Int) -> Date {
        stockholm.date(from: DateComponents(year: 2026, month: 10, day: day, hour: hour))!
    }

    @Test func aNightAcrossTheAutumnClockChangeKeepsWallClockPositions() {
        let evening = date(24, 0)
        #expect(NightAxis.offset(date(24, 23), evening: evening, calendar: stockholm) == 11)
        #expect(NightAxis.offset(date(25, 7), evening: evening, calendar: stockholm) == 19)
    }

    @Test func axisValuesNameTheirHourOfDay() {
        #expect(NightAxis.hourOfDay(9) == 21)
        #expect(NightAxis.hourOfDay(12) == 0)
        #expect(NightAxis.hourOfDay(21) == 9)
    }
}
