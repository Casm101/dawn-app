import Foundation
import Testing
@testable import DawnCore

/// What a chosen alarm time means for the night before it.
struct AlarmSleepPreviewTests {
    private typealias F = SleepFixture

    private func preview(ring: Date, nights: Int = 7, need: Double = 480, window: Int = 30) -> AlarmSleepPreview {
        let sessions = EnergyFixture.nights(nights, endingMorning: 7)
        let habitual = HabitualSleep(sessions: sessions, usual: EnergyFixture.usual, now: F.at(7, "20:00"), calendar: F.calendar)
        return AlarmSleepPreview(ring: ring, habitual: habitual, need: F.minutes(need), windowMinutes: window, calendar: F.calendar)
    }

    @Test func theWakeZoneIsHalfAnHourEitherSideOfTheHabitualWake() {
        let night = preview(ring: F.at(8, "07:00"))
        #expect(night.wakeZone == DateInterval(start: F.at(8, "06:30"), end: F.at(8, "07:30")))
        #expect(night.bedtime == F.at(7, "23:00"))
    }

    @Test func anEarlyAlarmAddsTheShortfallAndIsFlaggedEarly() {
        let night = preview(ring: F.at(8, "06:00"))
        #expect(night.debtChange == F.minutes(60))
        #expect(night.addsDebt)
        #expect(night.isEarly)
    }

    @Test func aLaterAlarmPaysDownWhatTheNightRunsOverNeed() {
        let night = preview(ring: F.at(8, "07:30"))
        #expect(night.debtChange == -F.minutes(30))
        #expect(!night.addsDebt)
        #expect(!night.isEarly)
    }

    @Test func anAlarmInsideTheZoneThatStillFallsShortAddsDebtButIsNotEarly() {
        let night = preview(ring: F.at(8, "06:45"), need: 510)
        #expect(night.addsDebt)
        #expect(!night.isEarly)
    }

    @Test func theWakeWindowEndsAtTheAlarmWithItsLength() {
        #expect(preview(ring: F.at(8, "07:00"), window: 20).window == DateInterval(start: F.at(8, "06:40"), end: F.at(8, "07:00")))
    }

    @Test func withTooFewNightsTheZoneComesFromTheUsualWakeTime() {
        let night = preview(ring: F.at(8, "07:00"), nights: 1)
        #expect(night.isLearning)
        #expect(night.wakeZone == DateInterval(start: F.at(8, "06:00"), end: F.at(8, "07:00")))
    }

    @Test func aDraggedTimeSnapsToFiveMinuteSteps() {
        #expect(AlarmSleepPreview.snap(F.at(8, "06:52")) == F.at(8, "06:50"))
        #expect(AlarmSleepPreview.snap(F.at(8, "06:53")) == F.at(8, "06:55"))
    }
}
