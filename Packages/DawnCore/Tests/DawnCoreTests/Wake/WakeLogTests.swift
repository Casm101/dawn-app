import Foundation
import Testing
@testable import DawnCore

struct WakeLogTests {
    private typealias F = SleepFixture

    private func outcome(_ day: Int, alarm: UUID = UUID(), id: UUID = UUID(), result: WakeResult = .wokeEarly) -> WakeOutcome {
        WakeOutcome(id: id, alarmID: alarm, windowStart: F.at(day, "06:30"), windowEnd: F.at(day, "07:00"), result: result)
    }

    @Test func anOutcomeArrivingTwiceIsKeptOnceAsItsLatestCopy() {
        var log = WakeLog()
        let id = UUID()
        log.record(outcome(1, id: id, result: .wokeEarly))
        log.record(outcome(1, id: id, result: .wokeAtEnd))
        #expect(log.outcomes.count == 1)
        #expect(log.latest?.result == .wokeAtEnd)
    }

    @Test func outcomesAreNewestFirstAndFoundByAlarm() {
        let alarm = UUID()
        var log = WakeLog()
        log.record(outcome(1, alarm: alarm))
        log.record(outcome(3))
        log.record(outcome(2, alarm: alarm))
        #expect(log.outcomes.map(\.windowEnd) == [F.at(3, "07:00"), F.at(2, "07:00"), F.at(1, "07:00")])
        #expect(log.outcomes(for: alarm).count == 2)
    }

    @Test func onlyTheNewestAreKept() {
        var log = WakeLog()
        for day in 0..<(Tuning.Wake.logSize + 5) { log.record(outcome(day)) }
        #expect(log.outcomes.count == Tuning.Wake.logSize)
        #expect(log.outcomes.last?.windowEnd == F.at(5, "07:00"))
    }
}
