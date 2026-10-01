import Foundation
import Testing
@testable import DawnCore

/// Debt and the energy schedule are worked out from the corrected nights, not from Health's.
struct CorrectedNightFollowTests {
    private typealias F = SleepFixture

    /// A week of 23:00–07:00 nights ending on the morning of day 7.
    private let imported = EnergyFixture.nights(7, endingMorning: 7)

    /// Last night cut to 23:00–05:00, as the user remembers it.
    private var edits: SleepEdits {
        var edits = SleepEdits()
        edits.save(NightCorrection(day: CalendarDay(F.at(6, "00:00"), calendar: F.calendar), segments: [DateInterval(start: F.at(6, "23:00"), end: F.at(7, "05:00"))]), calendar: F.calendar)
        return edits
    }

    @Test func debtGrowsWhenLastNightIsCorrectedShorter() throws {
        let need = 8 * 3600.0
        let before = try #require(DebtSummary(sessions: imported, need: need, now: F.at(7, "12:00"), calendar: F.calendar))
        let after = try #require(DebtSummary(sessions: edits.apply(to: imported, calendar: F.calendar), need: need, now: F.at(7, "12:00"), calendar: F.calendar))
        #expect(after.hours > before.hours)
    }

    @Test func theDayStartsAtTheCorrectedWake() {
        let corrected = edits.apply(to: imported, calendar: F.calendar)
        let forecast = EnergyForecast(sessions: corrected, usual: EnergyFixture.usual, now: F.at(7, "09:00"), calendar: F.calendar)
        #expect(forecast.today.wake == F.at(7, "05:00"))
    }
}
