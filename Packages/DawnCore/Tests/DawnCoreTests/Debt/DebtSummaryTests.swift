import Foundation
import Testing
@testable import DawnCore

struct DebtSummaryTests {
    private typealias D = DebtFixture

    private func summary(_ sessions: [SleepSession], need: Double = 8) -> DebtSummary? {
        DebtSummary(sessions: sessions, need: need * D.hour, now: D.today.addingTimeInterval(12 * D.hour), calendar: D.calendar)
    }

    @Test func aFirstNightHasNoChangeToShow() throws {
        let summary = try #require(summary([D.night(0, hours: 6)]))
        #expect(summary.change == nil)
    }

    @Test func theChangeIsTodayMinusYesterday() throws {
        let weights = DebtWeights.weights()
        let summary = try #require(summary([D.night(0, hours: 6), D.night(1, hours: 8)]))
        #expect(abs(try #require(summary.change) - 14 * weights[0] * 2) < 1e-6)
    }

    @Test func theBandFollowsTheHours() throws {
        #expect(try #require(summary((0..<14).map { D.night($0, hours: 7.5) })).band == .building)
        #expect(try #require(summary((0..<14).map { D.night($0, hours: 7) })).band == .high)
        #expect(try #require(summary((0..<14).map { D.night($0, hours: 8) })).band == .okay)
    }

    @Test func noSleepInTheWindowHasNoSummary() {
        #expect(summary([]) == nil)
    }
}
