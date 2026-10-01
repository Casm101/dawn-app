import Foundation
import Testing
@testable import DawnCore

/// The model's processes against the published constants.
struct AlertnessModelTests {
    @Test func eightHoursOfSleepFromHighPressureRecoverToFourteen() {
        // The recovery rate is defined so that 8 hours of sleep take S from 7.96 to 14.0.
        #expect(abs(AlertnessModel.pressure(afterSleeping: 8, from: 7.96) - 14.0) < 0.01)
    }

    @Test func pressureFallsTowardTheLowerAsymptoteWhileAwake() {
        let after16 = AlertnessModel.pressure(afterWaking: 16, from: 14.0)
        #expect(abs(after16 - (2.4 + 11.6 * exp(-0.0353 * 16))) < 1e-9)
        #expect(AlertnessModel.pressure(afterWaking: 1000, from: 14.0) > 2.4)
    }

    @Test func theRhythmsPeakAtThePeakHourAndBottomOutTwelveHoursLater() {
        #expect(abs(AlertnessModel.rhythm(atHour: 16, peakHour: 16) - 2.5) < 1e-9)
        #expect(abs(AlertnessModel.rhythm(atHour: 4, peakHour: 16) + 2.5) < 1e-9)
        #expect(AlertnessModel.rhythm(atHour: 10, peakHour: 16) < AlertnessModel.rhythm(atHour: 16, peakHour: 16))
    }

    @Test func inertiaStartsLowAndLastsAboutAnHourAndAHalf() {
        #expect(abs(AlertnessModel.inertia(afterWaking: 0) + 5.72) < 1e-9)
        let lasts = AlertnessModel.inertiaLasts(until: -0.5) / 60
        #expect(abs(lasts - 96.8) < 0.5)
    }

    @Test func aRegularEightHourSleeperSettlesNearTheTopOfTheScale() {
        let steady = AlertnessModel.steadyPressure(sleep: 8 * 3600, wake: 16 * 3600)
        #expect(abs(steady.atWake - 14.05) < 0.05)
        #expect(steady.atSleep < steady.atWake)
    }

    @Test func theCurveRunsOnAFiveMinuteGrid() {
        let wake = SleepFixture.at(1, "07:00")
        let curve = EnergyCurve(
            wake: wake, end: SleepFixture.at(1, "08:00"), pressureAtWake: 14, peakHour: 16, calendar: SleepFixture.calendar
        )
        #expect(curve.points.count == 13)
        #expect(curve.points[1].date.timeIntervalSince(wake) == 300)
        #expect(EnergyCurve.level(14.3) == 1)
        #expect(EnergyCurve.level(1) == 0)
    }
}
