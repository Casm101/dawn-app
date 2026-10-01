import Foundation
import Testing
@testable import DawnCore

struct DebtSummaryTests {
    private typealias D = DebtFixture

    private func makeSummary(_ sessions: [SleepSession], need: Double = 8) -> DebtSummary? {
        DebtSummary(sessions: sessions, need: need * D.hour, now: D.today.addingTimeInterval(12 * D.hour), calendar: D.calendar)
    }

    @Test func aFirstNightHasNoChangeToShow() throws {
        let summary = try #require(makeSummary([D.night(0, hours: 6)]))
        #expect(summary.change == nil)
    }

    @Test func theChangeIsTodayMinusYesterdayAsShownToOneDecimal() throws {
        let weights = DebtWeights.weights()
        let summary = try #require(makeSummary([D.night(0, hours: 6), D.night(1, hours: 8)]))
        let shownToday = (14 * weights[0] * 2 * 10).rounded() / 10
        #expect(abs(try #require(summary.change) - shownToday) < 1e-9)
    }

    @Test func theBandFollowsTheHours() throws {
        #expect(try #require(makeSummary((0..<14).map { D.night($0, hours: 7.5) })).band == .building)
        #expect(try #require(makeSummary((0..<14).map { D.night($0, hours: 7) })).band == .high)
        #expect(try #require(makeSummary((0..<14).map { D.night($0, hours: 8) })).band == .okay)
    }

    @Test func theBandAgreesWithTheNumberShown() throws {
        let weights = DebtWeights.weights()
        let hoursShort = 4.96 / (14 * weights[0])
        let summary = try #require(makeSummary([D.night(0, hours: 8 - hoursShort)]))
        #expect(summary.hours == 5.0)
        #expect(summary.band == .building)
    }

    @Test func noSleepInTheWindowHasNoSummary() {
        #expect(makeSummary([]) == nil)
    }
}
