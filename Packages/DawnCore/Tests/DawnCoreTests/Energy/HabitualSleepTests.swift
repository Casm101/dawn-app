import Foundation
import Testing
@testable import DawnCore

struct HabitualSleepTests {
    private typealias F = SleepFixture

    private func habitual(_ sessions: [SleepSession], now: Date) -> HabitualSleep {
        HabitualSleep(sessions: sessions, usual: EnergyFixture.usual, now: now, calendar: F.calendar)
    }

    @Test func fewerThanThreeNightsUseTheUsualTimesAndAreLearning() {
        let result = habitual(EnergyFixture.nights(2, endingMorning: 3), now: F.at(3, "12:00"))
        #expect(result.isLearning)
        #expect(result.bedtime == EnergyFixture.usual.bedtime)
        #expect(result.wakeTime == EnergyFixture.usual.wakeTime)
    }

    @Test func theLastThreeNightsCountTwice() {
        let samples = [
            F.sample(0, "23:00", "07:00", .core), F.sample(1, "23:30", "07:10", .core),
            F.sample(3, "00:30", "07:20", .core), F.sample(3, "23:50", "06:50", .core),
        ]
        let result = habitual(SessionGrouper.sessions(from: samples, calendar: F.calendar), now: F.at(4, "12:00"))
        #expect(!result.isLearning)
        #expect(result.bedtime == ClockTime(hour: 23, minute: 50)!)
        #expect(result.wakeTime == ClockTime(hour: 7, minute: 10)!)
    }

    @Test func nightsOlderThanAWeekAndNapsAreLeftOut() {
        var sessions = EnergyFixture.nights(2, endingMorning: 9)
        sessions += EnergyFixture.nights(3, endingMorning: 1, bed: "21:00", wake: "05:00")
        sessions += SessionGrouper.sessions(from: [F.sample(8, "14:00", "14:40", .core)], calendar: F.calendar)
        #expect(habitual(sessions, now: F.at(9, "12:00")).isLearning)
    }

    @Test func theMedianIsTakenRoundTheClock() {
        let times = [ClockTime(hour: 23, minute: 0)!, ClockTime(hour: 1, minute: 0)!, ClockTime(hour: 0, minute: 0)!]
        #expect(ClockTime.median(times, weights: [1, 1, 1]) == ClockTime(hour: 0, minute: 0)!)
    }

    @Test func theHabitualNightLengthWrapsMidnight() {
        let result = habitual(EnergyFixture.nights(4, endingMorning: 5, bed: "23:30", wake: "07:00"), now: F.at(5, "12:00"))
        #expect(result.nightLength == 7.5 * 3600)
    }
}
