import Foundation
import Testing
@testable import DawnCore

struct SessionGrouperTests {
    private typealias F = SleepFixture

    private func group(_ samples: [SleepSample]) -> [SleepSession] {
        SessionGrouper.sessions(from: samples, calendar: F.calendar)
    }

    @Test func samplesWithGapsUnderThreeHoursAreOneNight() throws {
        let sessions = group([
            F.sample(0, "23:00", "01:00", .unspecified),
            F.sample(1, "02:30", "04:00", .unspecified),
            F.sample(1, "06:59", "07:30", .unspecified),
        ])
        let night = try #require(sessions.first)
        #expect(sessions.count == 1)
        #expect(night.start == F.at(0, "23:00"))
        #expect(night.end == F.at(1, "07:30"))
    }

    @Test func aGapOfThreeHoursOrMoreStartsANewSession() {
        let sessions = group([
            F.sample(0, "22:00", "23:00", .unspecified),
            F.sample(1, "02:00", "07:00", .unspecified),
        ])
        #expect(sessions.count == 2)
    }

    @Test func asleepTimeExcludesAwakeSamples() throws {
        let night = try #require(group([
            F.sample(0, "23:00", "02:00", .core),
            F.sample(1, "02:00", "02:20", .awake),
            F.sample(1, "02:20", "07:00", .deep),
        ]).first)
        #expect(night.asleep == F.minutes(180 + 280))
        #expect(night.awake == F.minutes(20))
    }

    @Test func uncoveredGapsInsideTheNightCountAsAwake() throws {
        let night = try #require(group([
            F.sample(0, "23:00", "03:00", .unspecified),
            F.sample(1, "03:45", "07:00", .unspecified),
        ]).first)
        #expect(night.awake == F.minutes(45))
    }

    @Test func awakeBeforeFallingAsleepAndAfterWakingIsTrimmed() throws {
        let night = try #require(group([
            F.sample(0, "22:30", "23:00", .awake),
            F.sample(0, "23:00", "06:30", .core),
            F.sample(1, "06:30", "06:50", .awake),
        ]).first)
        #expect(night.start == F.at(0, "23:00"))
        #expect(night.end == F.at(1, "06:30"))
        #expect(night.awake == 0)
    }

    @Test func stageTotalsAreReportedWhenSamplesCarryStages() throws {
        let night = try #require(group([
            F.sample(0, "23:00", "01:00", .core),
            F.sample(1, "01:00", "01:40", .deep),
            F.sample(1, "01:40", "01:50", .awake),
            F.sample(1, "01:50", "03:00", .rem),
        ]).first)
        let totals = try #require(night.stageTotals)
        #expect(totals == StageTotals(awake: F.minutes(10), rem: F.minutes(70), core: F.minutes(120), deep: F.minutes(40)))
    }

    @Test func stageTotalsAreAbsentWhenSamplesCarryNoStages() throws {
        let night = try #require(group([
            F.sample(0, "23:00", "02:00", .unspecified),
            F.sample(1, "02:00", "02:20", .awake),
            F.sample(1, "02:20", "07:00", .unspecified),
        ]).first)
        #expect(night.stageTotals == nil)
    }

    @Test func theNightCarriesItsSamplesSource() throws {
        let night = try #require(group([F.sample(0, "23:00", "07:00", .core, source: "Ana's Apple Watch")]).first)
        #expect(night.source == "Ana's Apple Watch")
    }

    @Test func overlappingSourcesAreNotCountedTwice() throws {
        let night = try #require(group([
            F.sample(0, "23:00", "07:00", .unspecified, source: "Sleep app"),
            F.sample(0, "23:10", "03:00", .core, source: "Apple Watch"),
            F.sample(1, "03:00", "06:50", .deep, source: "Apple Watch"),
        ]).first)
        #expect(night.source == "Apple Watch")
        #expect(night.asleep == F.minutes(460))
    }

    @Test func overlappingSamplesFromOneSourceAreFlattened() throws {
        let night = try #require(group([
            F.sample(0, "23:00", "02:00", .unspecified),
            F.sample(1, "01:00", "03:00", .unspecified),
        ]).first)
        #expect(night.asleep == F.minutes(240))
    }

    @Test func awakeOnlyClustersAreNotSessions() {
        #expect(group([F.sample(1, "14:00", "14:30", .awake)]).isEmpty)
    }
}
