import Foundation
import Testing
@testable import DawnCore

/// Corrections and added naps laid over what Health imports.
struct SleepEditsTests {
    private typealias F = SleepFixture

    /// Health's night: 23:00–03:00 core, 03:00–07:00 deep, on the fixture's first evening.
    private var imported: [SleepSession] {
        SessionGrouper.sessions(from: [F.sample(0, "23:00", "03:00", .core), F.sample(1, "03:00", "07:00", .deep)], calendar: F.calendar)
    }

    private let day = CalendarDay(SleepFixture.at(0, "00:00"), calendar: SleepFixture.calendar)

    private func corrected(_ segments: [DateInterval]) -> SleepEdits {
        var edits = SleepEdits()
        edits.save(NightCorrection(day: day, segments: segments), calendar: F.calendar)
        return edits
    }

    @Test func aCorrectionReplacesTheEveningKeepingStagesWhereTheyOverlap() throws {
        let edits = corrected([DateInterval(start: F.at(0, "22:30"), end: F.at(1, "02:00")), DateInterval(start: F.at(1, "02:30"), end: F.at(1, "07:00"))])
        let nights = edits.apply(to: imported, calendar: F.calendar).filter { $0.kind == .night }
        let night = try #require(nights.first)
        #expect(nights.count == 1)
        #expect(night.start == F.at(0, "22:30"))
        #expect(night.asleep == F.minutes(210 + 270))
        #expect(night.awake == F.minutes(30))
        let totals = try #require(night.stageTotals)
        #expect(totals.unspecified == F.minutes(30))
        #expect(totals.deep == F.minutes(240))
    }

    @Test func aCorrectionOutlivesAFreshImport() throws {
        let edits = corrected([DateInterval(start: F.at(0, "23:00"), end: F.at(1, "06:00"))])
        let fresh = SessionGrouper.sessions(from: [F.sample(0, "23:10", "07:20", .core)], calendar: F.calendar)
        let night = try #require(edits.apply(to: fresh, calendar: F.calendar).first)
        #expect(night.end == F.at(1, "06:00"))
    }

    @Test func resettingGoesBackToHealth() {
        var edits = corrected([DateInterval(start: F.at(0, "23:00"), end: F.at(1, "06:00"))])
        edits.reset(day)
        #expect(edits.apply(to: imported, calendar: F.calendar) == imported)
    }

    @Test func deletingEveryStretchLeavesTheEveningEmpty() {
        #expect(corrected([]).apply(to: imported, calendar: F.calendar).isEmpty)
    }

    @Test func aCorrectionStillStandsInForItsNightAfterATimeZoneChange() throws {
        var newYork = Calendar(identifier: .gregorian)
        newYork.timeZone = try #require(TimeZone(identifier: "America/New_York"))
        let edits = corrected([DateInterval(start: F.at(0, "23:00"), end: F.at(1, "06:00"))])
        let nights = edits.apply(to: imported, calendar: newYork).filter { $0.kind == .night }
        #expect(nights.count == 1)
        #expect(nights.first?.end == F.at(1, "06:00"))
    }

    @Test func pruningKeepsEveryEditDebtStillCountsAndDropsTheRest() {
        var edits = corrected([DateInterval(start: F.at(0, "23:00"), end: F.at(1, "04:00"))])
        edits.add(ManualNap(start: F.at(1, "14:00"), end: F.at(1, "14:40")), existing: [], now: F.at(1, "18:00"), calendar: F.calendar)
        for day in [14, 15, 16] {
            let now = F.at(day, "09:00"), kept = edits.pruned(now: now, calendar: F.calendar)
            for through in [F.at(day - 1, "00:00"), F.at(day, "00:00")] {
                #expect(debt(edits, through: through) == debt(kept, through: through))
            }
        }
        #expect(edits.pruned(now: F.at(15, "09:00"), calendar: F.calendar) == edits)
        let gone = edits.pruned(now: F.at(17, "09:00"), calendar: F.calendar)
        #expect(gone.corrections.isEmpty && gone.naps.isEmpty)
    }

    private func debt(_ edits: SleepEdits, through day: Date) -> TimeInterval? {
        let days = SleepLedger.days(from: edits.apply(to: imported, calendar: F.calendar), calendar: F.calendar)
        return SleepDebt.debt(days: days, need: F.minutes(480), through: day, calendar: F.calendar)
    }

    @Test func editsAreLimitedToTheLastFourteenDays() {
        #expect(SleepEdits.isEditable(day: F.at(1, "00:00"), now: F.at(14, "09:00"), calendar: F.calendar))
        #expect(!SleepEdits.isEditable(day: F.at(0, "00:00"), now: F.at(14, "09:00"), calendar: F.calendar))
    }

    @Test func editsSurviveBeingSavedAndReadBack() throws {
        var edits = corrected([DateInterval(start: F.at(0, "23:00"), end: F.at(1, "06:00"))])
        edits.add(ManualNap(start: F.at(1, "14:00"), end: F.at(1, "14:40")), existing: [], now: F.at(1, "18:00"), calendar: F.calendar)
        let file = JSONFile<SleepEdits>(url: FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID()).json"))
        try file.write(edits)
        #expect(try file.read() == edits)
    }

    @Test func aCorrectionThatWouldMoveTheSleepToAnotherEveningIsRefused() {
        var edits = SleepEdits()
        let later = NightCorrection(day: day, segments: [DateInterval(start: F.at(1, "12:30"), end: F.at(1, "15:00"))])
        #expect(edits.save(later, calendar: F.calendar) == .movesNight)
        #expect(edits.corrections.isEmpty)
    }
}
