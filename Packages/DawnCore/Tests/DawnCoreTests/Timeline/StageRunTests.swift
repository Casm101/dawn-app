import Foundation
import Testing
@testable import DawnCore

struct StageRunTests {
    private typealias F = SleepFixture
    private let window = DateInterval(start: SleepFixture.at(0, "18:00"), end: SleepFixture.at(1, "18:00"))

    private func runs(_ samples: [SleepSample]) -> [StageRun] {
        StageRun.runs(of: SessionGrouper.sessions(from: samples, calendar: F.calendar), in: window)
    }

    @Test func consecutiveSamplesOfOneStageBecomeOneRun() {
        let runs = runs([F.sample(0, "23:00", "00:00", .core), F.sample(1, "00:00", "01:00", .core), F.sample(1, "01:00", "02:00", .deep)])
        #expect(runs.map(\.stage) == [.core, .deep])
        #expect(runs[0].end == F.at(1, "01:00"))
    }

    @Test func aNightWithoutStagesHasNoRail() {
        #expect(runs([F.sample(0, "23:00", "07:00", .unspecified)]).isEmpty)
    }

    @Test func runsAreClippedToTheWindow() {
        let runs = runs([F.sample(1, "16:00", "17:00", .core), F.sample(1, "17:00", "19:00", .rem)])
        #expect(runs.last?.end == F.at(1, "18:00"))
    }

    @Test func lanesRunFromAwakeToDeep() {
        #expect([SleepStage.awake, .rem, .core, .deep].map(StageLane.lane) == [0, 1, 2, 3])
    }
}
