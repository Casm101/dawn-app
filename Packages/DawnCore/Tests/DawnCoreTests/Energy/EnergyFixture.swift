import Foundation
@testable import DawnCore

/// Sleep histories for the energy tests, on the UTC sleep fixture's calendar.
enum EnergyFixture {
    private typealias F = SleepFixture

    /// One night a day for `count` days ending on the morning of `lastMorning`, each from `bed` to `wake`.
    static func nights(_ count: Int, endingMorning lastMorning: Int, bed: String = "23:00", wake: String = "07:00") -> [SleepSession] {
        let samples = (0..<count).map { offset in
            let evening = lastMorning - 1 - offset
            let startsAfterMidnight = bed < "12:00"
            return F.sample(startsAfterMidnight ? evening + 1 : evening, bed, wake, .core)
        }
        return SessionGrouper.sessions(from: samples, calendar: F.calendar)
    }

    static let usual = UsualSleep(bedtime: ClockTime(hour: 22, minute: 30)!, wakeTime: ClockTime(hour: 6, minute: 30)!)

    static func clock(_ date: Date) -> String {
        let parts = F.calendar.dateComponents([.hour, .minute], from: date)
        return String(format: "%02d:%02d", parts.hour ?? 0, parts.minute ?? 0)
    }

    /// Each phase as "name start-end" in clock time, for comparing whole schedules at a glance.
    static func describe(_ schedule: EnergySchedule) -> [String] {
        schedule.phases.map { "\($0.phase.rawValue) \(clock($0.start))-\(clock($0.end))" }
    }
}
