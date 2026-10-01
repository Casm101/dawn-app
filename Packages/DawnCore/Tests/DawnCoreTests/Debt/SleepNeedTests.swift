import Foundation
import Testing
@testable import DawnCore

struct SleepNeedTests {
    private let hour: TimeInterval = 3600
    private let minute: TimeInterval = 60
    private let start = DebtFixture.today
    private func week(_ count: Double) -> Date { start.addingTimeInterval(count * 7 * 86_400) }

    @Test func needSeedsAtEightHoursFifteen() {
        #expect(SleepNeed().value == 8 * hour + 15 * minute)
    }

    @Test func fewerThanThreeAlarmFreeNightsChangeNothing() {
        var need = SleepNeed()
        need.learn(fromFreeNights: [7 * hour, 7 * hour], now: start)
        #expect(need.value == SleepNeed().value)
    }

    @Test func needMovesATenthOfTheWayToTheMedian() {
        var need = SleepNeed()
        need.learn(fromFreeNights: Array(repeating: 7 * hour, count: 5), now: start)
        #expect(abs(need.value - (8 * hour + 7.5 * minute)) < 1e-6)
    }

    @Test func needMovesAtMostTenMinutesAWeek() {
        var need = SleepNeed()
        let nights = Array(repeating: 5 * hour, count: 10)
        need.learn(fromFreeNights: nights, now: start)
        #expect(need.value == 8 * hour + 5 * minute)
        need.learn(fromFreeNights: nights, now: start.addingTimeInterval(3600))
        #expect(abs(need.value - (8 * hour + 5 * minute)) < 10)
        need.learn(fromFreeNights: nights, now: week(1))
        #expect(abs(need.value - (7 * hour + 55 * minute)) < 1e-6)
    }

    @Test func theMedianComesFromTheLatestTenFreeNights() {
        var need = SleepNeed()
        let nights = Array(repeating: 11 * hour, count: 20) + Array(repeating: 7 * hour, count: 10)
        need.learn(fromFreeNights: nights, now: start)
        #expect(need.value < SleepNeed().value)
    }

    @Test func needStaysBetweenFiveAndElevenAndAHalfHours() {
        var need = SleepNeed()
        need.set(12 * hour)
        #expect(need.value == 11.5 * hour)
        need.set(4 * hour)
        #expect(need.value == 5 * hour)
    }

    @Test func aNeedSetByHandStopsLearningUntilResumed() {
        var need = SleepNeed()
        need.set(7 * hour)
        need.learn(fromFreeNights: Array(repeating: 9 * hour, count: 5), now: start)
        #expect(need.value == 7 * hour)
        need.resumeLearning()
        need.learn(fromFreeNights: Array(repeating: 9 * hour, count: 5), now: start)
        #expect(need.value > 7 * hour)
    }
}
