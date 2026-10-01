import Foundation
import Testing
@testable import DawnCore

struct RecentSleepTests {
    private typealias F = SleepFixture

    private func sessions(_ samples: [SleepSample]) -> [SleepSession] {
        SessionGrouper.sessions(from: samples, calendar: F.calendar)
    }

    @Test func lastNightIsTheMostRecentNight() throws {
        let recent = RecentSleep(sessions: sessions([
            F.sample(0, "23:00", "07:00", .core),
            F.sample(1, "23:30", "06:45", .core),
        ]), now: F.at(2, "12:00"))
        let lastNight = try #require(recent.lastNight)
        #expect(lastNight.start == F.at(1, "23:30"))
    }

    @Test func aNapIsListedAsANapAndNeverAsLastNight() throws {
        let recent = RecentSleep(sessions: sessions([
            F.sample(0, "23:00", "07:00", .core),
            F.sample(1, "14:00", "14:40", .core),
        ]), now: F.at(1, "18:00"))
        #expect(recent.lastNight?.start == F.at(0, "23:00"))
        #expect(recent.naps.map(\.start) == [F.at(1, "14:00")])
    }

    @Test func nothingInThePastTwoDaysIsEmpty() {
        let recent = RecentSleep(sessions: sessions([F.sample(0, "23:00", "07:00", .core)]), now: F.at(3, "08:00"))
        #expect(recent.lastNight == nil)
        #expect(recent.isEmpty)
    }

    @Test func noSessionsAtAllIsEmpty() {
        #expect(RecentSleep(sessions: [], now: F.at(1, "08:00")).isEmpty)
    }

    @Test func aNightThatEndedJustInsideTheWindowStillCounts() {
        let recent = RecentSleep(sessions: sessions([F.sample(0, "23:00", "07:00", .core)]), now: F.at(3, "06:59"))
        #expect(recent.lastNight != nil)
    }
}
