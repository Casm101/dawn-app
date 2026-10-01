import Foundation
import Testing
@testable import DawnCore

struct EnergyForecastCacheTests {
    private typealias F = SleepFixture

    @Test func theCurveIsWorkedOutOnceUntilANightChanges() {
        var cache = EnergyForecastCache()
        var sessions = EnergyFixture.nights(6, endingMorning: 6)
        let usual = EnergyFixture.usual
        let first = cache.forecast(sessions: sessions, usual: usual, now: F.at(6, "10:00"), calendar: F.calendar)
        let again = cache.forecast(sessions: sessions, usual: usual, now: F.at(6, "15:30"), calendar: F.calendar)
        #expect(cache.computations == 1)
        #expect(again == first)

        sessions += SessionGrouper.sessions(from: [F.sample(6, "23:00", "06:50", .core)], calendar: F.calendar)
        _ = cache.forecast(sessions: sessions, usual: usual, now: F.at(7, "08:00"), calendar: F.calendar)
        #expect(cache.computations == 2)
    }

    @Test func changingTheUsualTimesOrMovingToTheNextDayWorksItOutAgain() {
        var cache = EnergyForecastCache()
        let sessions = EnergyFixture.nights(2, endingMorning: 3)
        _ = cache.forecast(sessions: sessions, usual: EnergyFixture.usual, now: F.at(3, "10:00"), calendar: F.calendar)
        _ = cache.forecast(sessions: sessions, usual: UsualSleep(), now: F.at(3, "10:00"), calendar: F.calendar)
        #expect(cache.computations == 2)
        _ = cache.forecast(sessions: sessions, usual: UsualSleep(), now: F.at(3, "23:59"), calendar: F.calendar)
        #expect(cache.computations == 3)
    }
}
