import Foundation
import Testing
@testable import DawnUI

struct DurationFormatTests {
    private let english = Locale(identifier: "en_US")

    @Test func hoursAndMinutesReadShort() {
        #expect(DurationFormat.short(6 * 3600 + 22 * 60, locale: english) == "6h 22m")
    }

    @Test func underAnHourShowsMinutesOnly() {
        #expect(DurationFormat.short(16 * 60, locale: english) == "16m")
    }

    @Test func secondsRoundToTheNearestMinute() {
        #expect(DurationFormat.short(16 * 60 + 31, locale: english) == "17m")
        #expect(DurationFormat.short(16 * 60 + 29, locale: english) == "16m")
    }

    @Test func nothingReadsAsZeroMinutes() {
        #expect(DurationFormat.short(0, locale: english) == "0m")
    }
}
