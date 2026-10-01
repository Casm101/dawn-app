import Foundation
import Testing
@testable import DawnCore

/// Each habit's time from the day's schedule.
struct HabitTimeTests {
    private typealias F = SleepFixture

    private func times(bed: String, wake: String) -> [Habit: String] {
        let sessions = EnergyFixture.nights(7, endingMorning: 7, bed: bed, wake: wake)
        let today = EnergyForecast(sessions: sessions, usual: EnergyFixture.usual, now: F.at(7, "12:00"), calendar: F.calendar).today
        return Dictionary(uniqueKeysWithValues: HabitTime.times(for: today).map { time in
            (time.habit, [time.start, time.end].compactMap { $0 }.map(EnergyFixture.clock).joined(separator: "-"))
        })
    }

    @Test func anElevenToSevenSleeperGetsTheTicketsOffsets() {
        #expect(times(bed: "23:00", wake: "07:00") == [
            .morningLight: "07:00-08:00", .caffeineCutoff: "12:03", .dimLights: "21:00",
            .windDown: "21:30", .melatonin: "16:30", .rateLastNight: "08:30",
        ])
    }

    @Test func theTimesMoveWithBedtimeAndWake() {
        #expect(times(bed: "00:00", wake: "08:00") == [
            .morningLight: "08:00-09:00", .caffeineCutoff: "13:03", .dimLights: "22:00",
            .windDown: "22:30", .melatonin: "17:30", .rateLastNight: "09:30",
        ])
    }

    @Test func aHabitIsOverAtItsEndOrItsMoment() throws {
        let today = EnergyForecast(sessions: EnergyFixture.nights(7, endingMorning: 7), usual: EnergyFixture.usual, now: F.at(7, "12:00"), calendar: F.calendar).today
        let all = HabitTime.times(for: today)
        #expect(try #require(all.first { $0.habit == .morningLight }).last == F.at(7, "08:00"))
        #expect(try #require(all.first { $0.habit == .windDown }).last == F.at(7, "21:30"))
    }
}
