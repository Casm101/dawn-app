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
        edits.save(NightCorrection(day: day, segments: segments))
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

    @Test func anAddedNapIsANapFromDawnAndCountsTowardsTheDay() throws {
        var edits = SleepEdits()
        #expect(edits.add(ManualNap(start: F.at(1, "14:00"), end: F.at(1, "14:40")), existing: [], now: F.at(1, "18:00"), calendar: F.calendar) == nil)
        let nap = try #require(edits.apply(to: imported, calendar: F.calendar).first { $0.kind == .nap })
        #expect(nap.source == Tuning.Edits.source)
        let days = SleepLedger.days(from: edits.apply(to: imported, calendar: F.calendar), calendar: F.calendar)
        #expect(days[F.at(1, "00:00")] == F.minutes(480 + 40))
    }

    @Test func aNapUnderTwentyMinutesOrOlderThanTwoWeeksIsRefused() {
        var edits = SleepEdits()
        #expect(edits.add(ManualNap(start: F.at(1, "14:00"), end: F.at(1, "14:15")), existing: [], now: F.at(1, "18:00"), calendar: F.calendar) == .tooShort)
        #expect(edits.add(ManualNap(start: F.at(0, "14:00"), end: F.at(0, "14:40")), existing: [], now: F.at(15, "12:00"), calendar: F.calendar) == .tooOld)
        #expect(edits.naps.isEmpty)
    }

    @Test func aNapEndingBeforeItStartsOrNotYetOverIsRefused() {
        var edits = SleepEdits()
        #expect(edits.add(ManualNap(start: F.at(1, "14:40"), end: F.at(1, "14:00")), existing: [], now: F.at(1, "18:00"), calendar: F.calendar) == .endsBeforeStart)
        #expect(edits.add(ManualNap(start: F.at(1, "17:40"), end: F.at(1, "18:20")), existing: [], now: F.at(1, "18:00"), calendar: F.calendar) == .inFuture)
        #expect(edits.naps.isEmpty)
    }

    @Test func anAddedNapThatSleepLaterOverlapsIsLeftOutUntilItNoLongerDoes() {
        var edits = SleepEdits()
        edits.add(ManualNap(start: F.at(1, "07:30"), end: F.at(1, "08:30")), existing: imported, now: F.at(1, "18:00"), calendar: F.calendar)
        edits.save(NightCorrection(day: day, segments: [DateInterval(start: F.at(0, "23:00"), end: F.at(1, "08:00"))]))
        let recorded = edits.apply(to: imported, calendar: F.calendar)
        #expect(!recorded.contains { $0.kind == .nap })
        #expect(edits.add(ManualNap(start: F.at(1, "08:10"), end: F.at(1, "08:40")), existing: recorded, now: F.at(1, "18:00"), calendar: F.calendar) == .overlaps)
        edits.reset(day)
        #expect(edits.apply(to: imported, calendar: F.calendar).contains { $0.kind == .nap })
    }

    @Test func aCorrectionStillStandsInForItsNightAfterATimeZoneChange() throws {
        var newYork = Calendar(identifier: .gregorian)
        newYork.timeZone = try #require(TimeZone(identifier: "America/New_York"))
        let edits = corrected([DateInterval(start: F.at(0, "23:00"), end: F.at(1, "06:00"))])
        let nights = edits.apply(to: imported, calendar: newYork).filter { $0.kind == .night }
        #expect(nights.count == 1)
        #expect(nights.first?.end == F.at(1, "06:00"))
    }

    @Test func editsOlderThanTwoWeeksAreDroppedSoHealthStandsForThoseDays() {
        var edits = corrected([DateInterval(start: F.at(0, "23:00"), end: F.at(1, "06:00"))])
        edits.add(ManualNap(start: F.at(1, "14:00"), end: F.at(1, "14:40")), existing: [], now: F.at(1, "18:00"), calendar: F.calendar)
        let kept = edits.pruned(now: F.at(14, "09:00"), calendar: F.calendar)
        #expect(kept.corrections.isEmpty)
        #expect(kept.naps.count == 1)
        #expect(edits.pruned(now: F.at(13, "09:00"), calendar: F.calendar) == edits)
    }

    @Test func aNapOverlappingSleepAlreadyRecordedIsRefused() {
        var edits = SleepEdits()
        #expect(edits.add(ManualNap(start: F.at(1, "06:30"), end: F.at(1, "07:30")), existing: imported, now: F.at(1, "18:00"), calendar: F.calendar) == .overlaps)
        edits.add(ManualNap(start: F.at(1, "14:00"), end: F.at(1, "14:40")), existing: [], now: F.at(1, "18:00"), calendar: F.calendar)
        let recorded = edits.apply(to: imported, calendar: F.calendar)
        #expect(edits.add(ManualNap(start: F.at(1, "14:20"), end: F.at(1, "15:00")), existing: recorded, now: F.at(1, "18:00"), calendar: F.calendar) == .overlaps)
        #expect(edits.naps.count == 1)
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
}
