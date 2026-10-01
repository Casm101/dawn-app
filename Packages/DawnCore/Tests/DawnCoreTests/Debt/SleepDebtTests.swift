import Foundation
import Testing
@testable import DawnCore

struct SleepDebtTests {
    private typealias D = DebtFixture
    private let weights = DebtWeights.weights()

    @Test func lastNightCarriesAboutFifteenPercentAndTheWeightsSumToOne() {
        #expect(abs(weights[0] - 0.15) < 0.005)
        #expect(abs(weights.reduce(0, +) - 1) < 1e-9)
        #expect(zip(weights, weights.dropFirst()).allSatisfy { $0 > $1 })
    }

    @Test func fourteenEqualShortNightsAddUpLikeAPlainSum() throws {
        let nights = (0..<14).map { D.night($0, hours: 6) }
        #expect(abs(try #require(D.debtHours(nights)) - 28) < 1e-6)
    }

    @Test func recentShortfallWeighsMoreThanAnOldOne() throws {
        let recent = (0..<14).map { D.night($0, hours: $0 == 0 ? 4 : 8) }
        let old = (0..<14).map { D.night($0, hours: $0 == 13 ? 4 : 8) }
        #expect(abs(try #require(D.debtHours(recent)) - 14 * weights[0] * 4) < 1e-6)
        #expect(abs(try #require(D.debtHours(old)) - 14 * weights[13] * 4) < 1e-6)
    }

    @Test func surplusPaysDownButDebtNeverGoesBelowZero() throws {
        let rested = (0..<14).map { D.night($0, hours: 9) }
        #expect(try #require(D.debtHours(rested)) == 0)
        let partly = [D.night(0, hours: 9), D.night(1, hours: 6)]
        #expect(abs(try #require(D.debtHours(partly)) - 14 * (weights[0] * -1 + weights[1] * 2)) < 1e-6)
        let fully = [D.night(0, hours: 10), D.night(1, hours: 6)]
        #expect(try #require(D.debtHours(fully)) == 0)
    }

    @Test func missingNightsCountAsNeitherShortfallNorSurplus() throws {
        let alone = [D.night(0, hours: 6)]
        let withEvenNights = [D.night(0, hours: 6)] + (1..<14).map { D.night($0, hours: 8) }
        #expect(abs(try #require(D.debtHours(alone)) - 14 * weights[0] * 2) < 1e-6)
        #expect(abs(try #require(D.debtHours(alone)) - (try #require(D.debtHours(withEvenNights)))) < 1e-6)
    }

    @Test func aNapCountsTowardItsDay() throws {
        let debt = try #require(D.debtHours([D.night(0, hours: 6), D.nap(0, minutes: 60)]))
        #expect(abs(debt - 14 * weights[0] * 1) < 1e-6)
    }

    @Test func aSingleNapIsCreditedAtMostNinetyMinutes() throws {
        let debt = try #require(D.debtHours([D.night(0, hours: 6), D.nap(0, minutes: 140)]))
        #expect(abs(debt - 14 * weights[0] * 0.5) < 1e-6)
    }

    @Test func aDayWithOnlyANapIsMissing() {
        #expect(D.debtHours([D.nap(0, minutes: 60)]) == nil)
    }

    @Test func nothingInTheWindowHasNoDebt() {
        #expect(D.debtHours([D.night(14, hours: 4)]) == nil)
    }

    @Test func yesterdaysValueUsesTheWindowEndingYesterday() throws {
        let nights = [D.night(0, hours: 8), D.night(1, hours: 6)]
        let yesterday = D.calendar.date(byAdding: .day, value: -1, to: D.today)!
        #expect(abs(try #require(D.debtHours(nights, on: yesterday)) - 14 * weights[0] * 2) < 1e-6)
    }
}
