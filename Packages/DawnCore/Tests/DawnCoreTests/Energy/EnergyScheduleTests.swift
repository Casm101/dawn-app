import Foundation
import Testing
@testable import DawnCore

/// Whole schedules from fixture histories, with the phase times they should give.
struct EnergyScheduleTests {
    private typealias F = SleepFixture

    private func forecast(_ sessions: [SleepSession], now: Date) -> EnergyForecast {
        EnergyForecast(sessions: sessions, usual: EnergyFixture.usual, now: now, calendar: F.calendar)
    }

    @Test func aRegularElevenToSevenSleeperGetsThePriorPhases() {
        let today = forecast(EnergyFixture.nights(7, endingMorning: 7), now: F.at(7, "10:00")).today
        #expect(!today.isLearning)
        #expect(EnergyFixture.describe(today) == [
            "grogginess 07:00-08:30", "morningPeak 08:30-13:30", "afternoonDip 13:30-16:00",
            "eveningPeak 16:00-21:30", "windDown 21:30-22:03", "melatoninWindow 22:03-23:03",
        ])
    }

    @Test func theMelatoninWindowOpensAnHourAfterOnsetTwoHoursBeforeBed() {
        let today = forecast(EnergyFixture.nights(5, endingMorning: 7, bed: "00:00", wake: "08:00"), now: F.at(7, "10:00")).today
        let window = today.span(of: .melatoninWindow)
        #expect(window.map { EnergyFixture.clock($0.start) } == "23:03")
        #expect(window.map { $0.end.timeIntervalSince($0.start) } == 3600)
        #expect(today.span(of: .windDown).map { EnergyFixture.clock($0.start) } == "22:30")
    }

    @Test func phasesRunInOrderWithNoGapsOrOverlapsFromWakeToBed() {
        for bed in ["21:30", "23:00", "01:00"] {
            let today = forecast(EnergyFixture.nights(6, endingMorning: 8, bed: bed, wake: "06:15"), now: F.at(8, "09:00")).today
            #expect(today.phases.first?.start == today.wake)
            #expect(today.phases.map(\.phase) == EnergyPhase.allCases)
            for (earlier, later) in zip(today.phases, today.phases.dropFirst()) { #expect(earlier.end == later.start) }
            #expect(today.end >= today.bedtime)
        }
    }

    @Test func aShortDayDropsThePhasesThereIsNoRoomFor() {
        let samples = [F.sample(7, "09:00", "19:00", .core)] + EnergyFixture.nights(4, endingMorning: 7).flatMap(\.samples)
        let sessions = SessionGrouper.sessions(from: samples, calendar: F.calendar)
        let today = forecast(sessions, now: F.at(7, "20:00")).today
        #expect(EnergyFixture.clock(today.wake) == "19:00")
        for (earlier, later) in zip(today.phases, today.phases.dropFirst()) { #expect(earlier.end == later.start) }
        #expect(today.span(of: .afternoonDip) == nil)
        #expect(today.span(of: .melatoninWindow) != nil)
    }

    @Test func fewerThanThreeNightsAnchorOnTheUsualTimesAndAreLearning() {
        let today = forecast(EnergyFixture.nights(2, endingMorning: 3, wake: "08:10"), now: F.at(3, "10:00")).today
        #expect(today.isLearning)
        #expect(EnergyFixture.clock(today.wake) == "06:30")
        #expect(EnergyFixture.clock(today.bedtime) == "22:30")
    }

    @Test func lastNightsActualWakeStartsTheDay() {
        var sessions = EnergyFixture.nights(5, endingMorning: 6)
        sessions += SessionGrouper.sessions(from: [F.sample(6, "23:10", "06:40", .core)], calendar: F.calendar)
        let today = forecast(sessions, now: F.at(7, "09:00")).today
        #expect(EnergyFixture.clock(today.wake) == "06:40")
        #expect(today.span(of: .grogginess).map { EnergyFixture.clock($0.end) } == "08:10")
    }

    @Test func afterTheMelatoninWindowTheNextDayIsShown() {
        let today = forecast(EnergyFixture.nights(7, endingMorning: 7), now: F.at(7, "23:30")).today
        #expect(today.wake == F.at(8, "07:00"))
    }

    @Test func aShorterNightLeavesLessEnergyThanAFullOne() {
        var short = EnergyFixture.nights(6, endingMorning: 6)
        short += SessionGrouper.sessions(from: [F.sample(7, "03:00", "07:00", .core)], calendar: F.calendar)
        let full = forecast(EnergyFixture.nights(7, endingMorning: 7), now: F.at(7, "10:00")).today
        let tired = forecast(short, now: F.at(7, "10:00")).today
        let noon = { (schedule: EnergySchedule) in schedule.curve.points.first { $0.date == F.at(7, "12:00") }?.alertness ?? 0 }
        // Twenty hours awake then four asleep leaves S about 1.1 lower at waking, about 0.9 by noon.
        #expect(noon(tired) < noon(full) - 0.5)
    }
}
