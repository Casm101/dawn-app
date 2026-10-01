import Foundation
import Testing
@testable import DawnCore

/// The model's processes against the published constants.
struct AlertnessModelTests {
    @Test func belowTheBrakeSleepRecoversInAStraightLine() {
        // S′1 = ss + t·g·(bl − ha): 0.3813 × (14.3 − 12.2) ≈ 0.80 an hour.
        #expect(abs(AlertnessModel.pressure(afterSleeping: 2, from: 8) - (8 + 2 * 0.3813 * 2.1)) < 1e-9)
    }

    @Test func aboveTheBrakeSleepRecoversExponentiallyAndJoinsTheLine() {
        // S′2 = ha − (ha − bl)·exp(g·(t − bt)), with bt where the line reaches bl.
        let brakeTime = (12.2 - 8) / (0.3813 * 2.1)
        #expect(abs(AlertnessModel.pressure(afterSleeping: brakeTime, from: 8) - 12.2) < 1e-9)
        let after = AlertnessModel.pressure(afterSleeping: brakeTime + 3, from: 8)
        #expect(abs(after - (14.3 - 2.1 * exp(-0.3813 * 3))) < 1e-9)
        #expect(abs(AlertnessModel.pressure(afterSleeping: 8, from: 12.2) - (14.3 - 2.1 * exp(-0.3813 * 8))) < 1e-9)
    }

    @Test func pressureFallsTowardTheLowerAsymptoteWhileAwake() {
        let after16 = AlertnessModel.pressure(afterWaking: 16, from: 14.0)
        #expect(abs(after16 - (2.4 + 11.6 * exp(-0.0353 * 16))) < 1e-9)
        #expect(AlertnessModel.pressure(afterWaking: 1000, from: 14.0) > 2.4)
    }

    @Test func theUltradianRhythmBottomsOutThreeHoursBeforeTheCircadianPeak() {
        // C = Cm + Ca·cos(2π/24·(tod − p)); U = Um + Ua·cos(2π/12·(tod − p − 3)).
        let p = 16.8
        let rhythm = { (hour: Double) in AlertnessModel.rhythm(atHour: hour, peakHour: p) }
        #expect(abs(rhythm(p) - (2.5 - 0.5 + 0.5 * cos(-.pi / 2))) < 1e-9)
        let ultradian = { (hour: Double) in rhythm(hour) - 2.5 * cos(2 * .pi * (hour - p) / 24) }
        #expect(abs(ultradian(p - 3) - (-1.0)) < 1e-9)
        #expect(abs(ultradian(p + 3) - 0.0) < 1e-9)
    }

    @Test func inertiaStartsLowAndLastsAboutAnHourAndAHalf() {
        #expect(abs(AlertnessModel.inertia(afterWaking: 0) + 5.72) < 1e-9)
        let lasts = AlertnessModel.inertiaLasts(until: -0.5) / 60
        #expect(abs(lasts - 96.8) < 0.5)
    }

    @Test func aRegularEightHourSleeperSettlesNearTheTopOfTheScale() {
        let steady = AlertnessModel.steadyPressure(sleep: 8 * 3600, wake: 16 * 3600)
        #expect(abs(steady.atWake - 13.82) < 0.05)
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
