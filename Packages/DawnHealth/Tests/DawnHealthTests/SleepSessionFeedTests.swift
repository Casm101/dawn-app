import DawnCore
import Foundation
import Testing
@testable import DawnHealth

struct SleepSessionFeedTests {
    private static let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        return calendar
    }()
    private static let now = calendar.date(from: DateComponents(year: 2026, month: 9, day: 30, hour: 9))!

    private static func sample(_ hoursBeforeNow: Double, _ hours: Double, _ stage: SleepStage) -> SleepSample {
        let start = now.addingTimeInterval(-hoursBeforeNow * 3600)
        return SleepSample(start: start, end: start.addingTimeInterval(hours * 3600), stage: stage, source: "Apple Watch")
    }

    private func feed(_ source: FakeSleepSampleSource) -> SleepSessionFeed {
        SleepSessionFeed(source: source, calendar: Self.calendar, now: { Self.now })
    }

    @Test func readsFromTheStartOfTheDayFifteenDaysAgoUntilNow() async throws {
        let source = FakeSleepSampleSource(samples: [])
        _ = try await feed(source).load()
        let interval = try #require(await source.requested.first)
        #expect(interval.start == Self.calendar.date(from: DateComponents(year: 2026, month: 9, day: 15)))
        #expect(interval.end == Self.now)
    }

    @Test func groupsWhatTheSourceReturnsIntoSessions() async throws {
        let source = FakeSleepSampleSource(samples: [Self.sample(10, 3, .unspecified), Self.sample(6.5, 4, .unspecified)])
        let sessions = try await feed(source).load()
        #expect(sessions.count == 1)
    }

    @Test func newSamplesAfterTheFirstReadArriveWithoutAskingAgain() async throws {
        let source = FakeSleepSampleSource(samples: [Self.sample(10, 8, .unspecified)])
        var updates = feed(source).updates().makeAsyncIterator()
        let first = try #require(try await updates.next())
        #expect(first.first?.stageTotals == nil)

        await source.replace(with: [Self.sample(10, 4, .core), Self.sample(6, 4, .deep)])
        source.reportChange()
        let second = try #require(try await updates.next())
        #expect(second.first?.stageTotals != nil)
    }
}
