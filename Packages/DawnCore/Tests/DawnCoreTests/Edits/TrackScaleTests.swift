import Foundation
import Testing
@testable import DawnCore

/// Moments on the night editor's track and the distances across it.
struct TrackScaleTests {
    private typealias F = SleepFixture
    private let scale = TrackScale(span: DateInterval(start: SleepFixture.at(0, "21:00"), end: SleepFixture.at(1, "09:00")))

    @Test func aMomentAndItsDistanceMapBothWays() {
        #expect(scale.x(F.at(1, "03:00"), width: 240) == 120)
        #expect(scale.date(60, width: 240) == F.at(1, "00:00"))
    }

    @Test func distancesPastEitherEndStopAtTheEnd() {
        #expect(scale.date(-30, width: 240) == F.at(0, "21:00"))
        #expect(scale.date(300, width: 240) == F.at(1, "09:00"))
    }

    @Test func widensToANightThatMovedPastItAndNeverShrinks() {
        var scale = scale
        scale.widen(to: DateInterval(start: F.at(0, "22:00"), end: F.at(1, "10:00")))
        #expect(scale.span == DateInterval(start: F.at(0, "21:00"), end: F.at(1, "10:00")))
    }
}
