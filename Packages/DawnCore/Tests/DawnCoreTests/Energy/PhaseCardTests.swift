import Foundation
import Testing
@testable import DawnCore

/// Home's carousel and the change since yesterday.
struct PhaseCardTests {
    private typealias F = SleepFixture

    private func span(_ phase: EnergyPhase, _ day: Int, _ start: String, _ end: String) -> PhaseSpan {
        PhaseSpan(phase: phase, start: F.at(day, start), end: F.at(day, end))
    }

    @Test func theChangeIsTheStartMovedByTheClock() {
        let today = span(.afternoonDip, 2, "13:45", "16:15")
        #expect(PhaseChange(today: today, yesterday: span(.afternoonDip, 1, "13:30", "16:00"), calendar: F.calendar) == .later(minutes: 15))
        #expect(PhaseChange(today: today, yesterday: span(.afternoonDip, 1, "14:05", "16:35"), calendar: F.calendar) == .earlier(minutes: 20))
        #expect(PhaseChange(today: today, yesterday: span(.afternoonDip, 1, "13:45", "16:15"), calendar: F.calendar) == .same)
        #expect(PhaseChange(today: today, yesterday: nil, calendar: F.calendar) == nil)
    }

    @Test func aStartMovingAcrossMidnightMovesMinutesNotADay() {
        let today = span(.melatoninWindow, 2, "00:10", "01:10")
        let yesterday = span(.melatoninWindow, 1, "23:50", "23:59")
        #expect(PhaseChange(today: today, yesterday: yesterday, calendar: F.calendar) == .later(minutes: 20))
    }

    @Test func theCurrentPhaseComesFirstThenTheOnesToCome() {
        let sessions = EnergyFixture.nights(7, endingMorning: 7)
        let forecast = EnergyForecast(sessions: sessions, usual: EnergyFixture.usual, now: F.at(7, "14:00"), calendar: F.calendar)
        let cards = PhaseCard.cards(for: forecast, now: F.at(7, "14:00"), calendar: F.calendar)
        #expect(cards.map(\.span.phase) == [.afternoonDip, .eveningPeak, .windDown, .melatoninWindow])
        #expect(cards.map(\.isCurrent) == [true, false, false, false])
        #expect(cards.allSatisfy { $0.change == .same })
    }

    @Test func aLaterWakeMovesTheMorningLater() {
        var sessions = EnergyFixture.nights(6, endingMorning: 6)
        sessions += SessionGrouper.sessions(from: [F.sample(6, "23:00", "07:40", .core)], calendar: F.calendar)
        let forecast = EnergyForecast(sessions: sessions, usual: EnergyFixture.usual, now: F.at(7, "08:00"), calendar: F.calendar)
        let cards = PhaseCard.cards(for: forecast, now: F.at(7, "08:00"), calendar: F.calendar)
        #expect(cards.first?.span.phase == .grogginess)
        #expect(cards.first?.change == .later(minutes: 40))
    }

    @Test func beforeWakingNothingIsCurrent() {
        let forecast = EnergyForecast(
            sessions: EnergyFixture.nights(7, endingMorning: 7), usual: EnergyFixture.usual, now: F.at(8, "05:00"), calendar: F.calendar
        )
        let cards = PhaseCard.cards(for: forecast, now: F.at(8, "05:00"), calendar: F.calendar)
        #expect(cards.count == EnergyPhase.allCases.count)
        #expect(!cards.contains { $0.isCurrent })
    }
}
