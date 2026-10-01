import Foundation
import Testing
@testable import DawnCore

struct SleepSegmentTests {
    private typealias F = SleepFixture

    private func night(_ samples: [SleepSample]) throws -> SleepSession {
        try #require(SessionGrouper.sessions(from: samples, calendar: F.calendar).first)
    }

    @Test func touchingAsleepSamplesAreOneSegment() throws {
        let session = try night([F.sample(0, "23:00", "01:00", .core), F.sample(1, "01:00", "03:00", .deep)])
        #expect(session.segments.count == 1)
        #expect(session.segments[0].start == F.at(0, "23:00"))
        #expect(session.segments[0].end == F.at(1, "03:00"))
    }

    @Test func anAwakeSampleSplitsSegments() throws {
        let session = try night([
            F.sample(0, "23:00", "01:00", .core), F.sample(1, "01:00", "01:20", .awake), F.sample(1, "01:20", "06:00", .core),
        ])
        #expect(session.segments.map(\.start) == [F.at(0, "23:00"), F.at(1, "01:20")])
        #expect(session.awakeGaps == [DateInterval(start: F.at(1, "01:00"), end: F.at(1, "01:20"))])
    }

    @Test func anUncoveredStretchSplitsSegments() throws {
        let session = try night([F.sample(0, "23:00", "02:00", .unspecified), F.sample(1, "02:45", "07:00", .unspecified)])
        #expect(session.segments.count == 2)
        #expect(abs((session.awakeGaps.first?.duration ?? 0) - 45 * 60) < 1e-6)
    }
}
