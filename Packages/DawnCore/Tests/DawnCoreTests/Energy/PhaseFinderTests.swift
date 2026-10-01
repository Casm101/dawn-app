import Foundation
import Testing
@testable import DawnCore

/// The finder on hand-made curves, where the answer is known.
struct PhaseFinderTests {
    private let wake = SleepFixture.at(1, "07:00")

    /// A curve every five minutes from wake for `hours`, shaped by `shape(hoursSinceWake)`.
    private func curve(hours: Double, _ shape: (Double) -> Double) -> EnergyCurve {
        let steps = Int(hours * 12)
        return EnergyCurve(points: (0...steps).map { step in
            EnergyPoint(date: wake.addingTimeInterval(Double(step) * 300), alertness: shape(Double(step) / 12))
        })
    }

    private func window(_ from: Double, _ to: Double) -> DateInterval {
        DateInterval(start: wake.addingTimeInterval(from * 3600), end: wake.addingTimeInterval(to * 3600))
    }

    @Test func aDipInsideTheWindowIsFound() {
        let dipped = curve(hours: 16) { 10 + abs($0 - 8) }
        #expect(PhaseFinder.lowest(in: dipped, within: window(5, 11)) == wake.addingTimeInterval(8 * 3600))
    }

    @Test func aCurveThatOnlyRisesHasNoDipOrPeak() {
        let rising = curve(hours: 16) { $0 }
        #expect(PhaseFinder.lowest(in: rising, within: window(5, 11)) == nil)
        #expect(PhaseFinder.highest(in: rising, within: window(5, 11)) == nil)
    }

    @Test func anExtremeAtTheEdgeOfTheWindowDoesNotCount() {
        let dipped = curve(hours: 16) { 10 + abs($0 - 5.25) }
        #expect(PhaseFinder.lowest(in: dipped, within: window(5, 11)) == nil)
    }

    @Test func aRippleSmallerThanTheToleranceIsFlat() {
        let ripple = curve(hours: 16) { 10 + 0.01 * abs($0 - 8) }
        #expect(PhaseFinder.lowest(in: ripple, within: window(5, 11)) == nil)
    }

    @Test func theDipGivesWayToPeaksFoundJustEitherSideOfIt() {
        // A dip eight hours after waking with peaks at seven and nine, inside the dip's usual width.
        let bump = { (hours: Double, centre: Double) in max(0, 1 - abs(hours - centre) / 0.9) }
        let shaped = curve(hours: 17) { 10 + bump($0, 7) + bump($0, 9) - bump($0, 8) }
        let phases = PhaseLayout.phases(curve: shaped, wake: wake, bedtime: SleepFixture.at(1, "23:00"))
        let dip = phases.first { $0.phase == .afternoonDip }
        #expect(dip?.start == wake.addingTimeInterval(7.5 * 3600))
        #expect(dip?.end == wake.addingTimeInterval(8.5 * 3600))
        #expect(phases.first { $0.phase == .morningPeak }?.contains(wake.addingTimeInterval(7 * 3600)) == true)
        #expect(phases.first { $0.phase == .eveningPeak }?.contains(wake.addingTimeInterval(9 * 3600)) == true)
    }

    @Test func aFoundDipCentresTheAfternoonDipAndFoundPeaksStayInTheirBands() {
        // Peaks three and eleven hours after waking, a dip at eight, each a two-hour triangle.
        let bump = { (hours: Double, centre: Double) in 2 * max(0, 1 - abs(hours - centre) / 2) }
        let shaped = curve(hours: 17) { 10 + bump($0, 3) + bump($0, 11) - bump($0, 8) }
        let bed = SleepFixture.at(1, "23:00")
        let phases = PhaseLayout.phases(curve: shaped, wake: wake, bedtime: bed)
        let dip = phases.first { $0.phase == .afternoonDip }
        #expect(dip.map { $0.start.addingTimeInterval($0.end.timeIntervalSince($0.start) / 2) } == wake.addingTimeInterval(8 * 3600))
        #expect(phases.first { $0.phase == .morningPeak }?.contains(wake.addingTimeInterval(3 * 3600)) == true)
        #expect(phases.first { $0.phase == .eveningPeak }?.contains(wake.addingTimeInterval(11 * 3600)) == true)
    }
}
