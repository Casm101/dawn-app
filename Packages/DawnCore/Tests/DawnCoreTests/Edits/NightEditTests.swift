import Foundation
import Testing
@testable import DawnCore

/// Moving edges, inserting gaps and deleting stretches of a night.
struct NightEditTests {
    private typealias F = SleepFixture

    /// 23:00–02:00 and 02:30–07:00 on the fixture's first night.
    private var night: NightEdit {
        NightEdit(segments: [DateInterval(start: F.at(0, "23:00"), end: F.at(1, "02:00")), DateInterval(start: F.at(1, "02:30"), end: F.at(1, "07:00"))])
    }

    @Test func edgesMoveInFiveMinuteSteps() {
        var edit = night
        #expect(edit.move(1, .end, to: F.at(1, "07:13")) == nil)
        #expect(edit.segments[1].end == F.at(1, "07:15"))
        edit.move(0, .start, to: F.at(0, "22:38"))
        #expect(edit.segments[0].start == F.at(0, "22:40"))
    }

    @Test func aStretchUnderTwentyMinutesIsRefusedAndNothingChanges() {
        var edit = night
        #expect(edit.move(0, .end, to: F.at(0, "23:15")) == .tooShort)
        #expect(edit == night)
    }

    @Test func anEdgeStopsAStepShortOfTheNextStretch() {
        var edit = night
        edit.move(0, .end, to: F.at(1, "03:00"))
        #expect(edit.segments[0].end == F.at(1, "02:25"))
        edit.move(1, .start, to: F.at(1, "01:00"))
        #expect(edit.segments[1].start == F.at(1, "02:30"))
    }

    @Test func pressingInsertsATenMinuteAwakeGapThatCanBeWidened() {
        var edit = night
        #expect(edit.insertGap(at: F.at(1, "04:02")) == nil)
        #expect(edit.segments.map(\.start) == [F.at(0, "23:00"), F.at(1, "02:30"), F.at(1, "04:10")])
        #expect(edit.segments[1].end == F.at(1, "04:00"))
        edit.move(2, .start, to: F.at(1, "04:30"))
        #expect(edit.segments[2].start == F.at(1, "04:30"))
    }

    @Test func aGapThatWouldLeaveAShortStretchIsRefused() {
        var edit = night
        #expect(edit.insertGap(at: F.at(1, "02:40")) == .tooShort)
        #expect(edit.insertGap(at: F.at(1, "06:45")) == .tooShort)
        #expect(edit == night)
    }

    @Test func aStretchCanBeDeleted() {
        var edit = night
        edit.delete(0)
        #expect(edit.segments == [DateInterval(start: F.at(1, "02:30"), end: F.at(1, "07:00"))])
    }

    @Test func theTrackLeavesTwoHoursEitherSide() {
        #expect(night.track == DateInterval(start: F.at(0, "21:00"), end: F.at(1, "09:00")))
    }
}
