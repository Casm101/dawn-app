import Foundation
import Testing
@testable import DawnCore

/// Ratings of last night.
struct NightRatingsTests {
    private typealias F = SleepFixture

    @Test func aRatingIsHeldToZeroToTenAndReplacesAnEarlierOne() {
        let day = CalendarDay(F.at(0, "00:00"), calendar: F.calendar)
        var ratings = NightRatings()
        ratings.rate(day, 12)
        #expect(ratings.score(for: day) == 10)
        ratings.rate(day, 6)
        #expect(ratings.score(for: day) == 6)
        ratings.rate(day, -1)
        #expect(ratings.score(for: day) == 0)
        #expect(ratings.ratings.count == 1)
    }

    @Test func theRatedNightIsTheOneEndingAtTheWake() {
        let sessions = EnergyFixture.nights(2, endingMorning: 7, bed: "01:30", wake: "09:00")
        #expect(NightRatings.night(endingAt: F.at(7, "09:00"), sessions: sessions, calendar: F.calendar) == CalendarDay(F.at(6, "00:00"), calendar: F.calendar))
        #expect(NightRatings.night(endingAt: F.at(9, "07:00"), sessions: sessions, calendar: F.calendar) == CalendarDay(F.at(8, "00:00"), calendar: F.calendar))
    }

    @Test func ratingsSurviveBeingSavedAndReadBack() throws {
        var ratings = NightRatings()
        ratings.rate(CalendarDay(F.at(0, "00:00"), calendar: F.calendar), 7)
        let file = JSONFile<NightRatings>(url: FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID()).json"))
        try file.write(ratings)
        #expect(try file.read() == ratings)
    }
}
