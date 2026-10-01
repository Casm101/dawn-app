import Foundation
import Testing
@testable import DawnCore

/// Naps added by hand, beside what Health imports.
struct AddedNapTests {
    private typealias F = SleepFixture

    /// Health's night: 23:00–03:00 core, 03:00–07:00 deep, on the fixture's first evening.
    private var imported: [SleepSession] {
        SessionGrouper.sessions(from: [F.sample(0, "23:00", "03:00", .core), F.sample(1, "03:00", "07:00", .deep)], calendar: F.calendar)
    }

    private let day = CalendarDay(SleepFixture.at(0, "00:00"), calendar: SleepFixture.calendar)

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
        edits.save(NightCorrection(day: day, segments: [DateInterval(start: F.at(0, "23:00"), end: F.at(1, "08:00"))]), calendar: F.calendar)
        let recorded = edits.apply(to: imported, calendar: F.calendar)
        #expect(!recorded.contains { $0.kind == .nap })
        #expect(edits.add(ManualNap(start: F.at(1, "08:10"), end: F.at(1, "08:40")), existing: recorded, now: F.at(1, "18:00"), calendar: F.calendar) == .overlaps)
        edits.reset(day)
        #expect(edits.apply(to: imported, calendar: F.calendar).contains { $0.kind == .nap })
    }

    @Test func aNapOverlappingSleepAlreadyRecordedIsRefused() {
        var edits = SleepEdits()
        #expect(edits.add(ManualNap(start: F.at(1, "06:30"), end: F.at(1, "07:30")), existing: imported, now: F.at(1, "18:00"), calendar: F.calendar) == .overlaps)
        edits.add(ManualNap(start: F.at(1, "14:00"), end: F.at(1, "14:40")), existing: [], now: F.at(1, "18:00"), calendar: F.calendar)
        let recorded = edits.apply(to: imported, calendar: F.calendar)
        #expect(edits.add(ManualNap(start: F.at(1, "14:20"), end: F.at(1, "15:00")), existing: recorded, now: F.at(1, "18:00"), calendar: F.calendar) == .overlaps)
        #expect(edits.naps.count == 1)
    }

}
