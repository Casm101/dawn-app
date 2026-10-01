import Foundation

/// One waking day: the curve from waking to the end of the melatonin window and the phases on it.
public struct EnergySchedule: Hashable, Sendable {
    public let wake: Date
    public let bedtime: Date
    public let curve: EnergyCurve
    public let phases: [PhaseSpan]
    /// True while the schedule stands on the user's usual times rather than their nights.
    public let isLearning: Bool

    public init(wake: Date, habitual: HabitualSleep, sessions: [SleepSession], calendar: Calendar) {
        let bedtime = Self.bedtime(after: wake, habitual: habitual, calendar: calendar)
        self.wake = wake
        self.bedtime = bedtime
        curve = EnergyCurve(
            wake: wake, end: MelatoninAnchors(bedtime: bedtime).windowEnd,
            pressureAtWake: SleepPressure.atWake(wake, sessions: sessions, habitual: habitual),
            peakHour: Self.circadianPeakHour(bedtime: habitual.bedtime), calendar: calendar
        )
        phases = PhaseLayout.phases(curve: curve, wake: wake, bedtime: bedtime)
        isLearning = habitual.isLearning
    }

    /// When the last phase ends.
    public var end: Date { phases.last?.end ?? bedtime }

    public func span(of phase: EnergyPhase) -> PhaseSpan? { phases.first { $0.phase == phase } }

    /// The hour of the day the circadian rhythm peaks for someone who goes to bed at `bedtime`.
    public static func circadianPeakHour(bedtime: ClockTime) -> Double {
        let minutes = Double(bedtime.minutesSinceMidnight) + Tuning.Energy.circadianPeakAfterBedtime / 60
        return minutes.truncatingRemainder(dividingBy: 1440) / 60
    }

    /// The first habitual bedtime at least `Tuning.Energy.shortestDay` after waking.
    public static func bedtime(after wake: Date, habitual: HabitualSleep, calendar: Calendar) -> Date {
        let earliest = wake.addingTimeInterval(Tuning.Energy.shortestDay)
        var bedtime = habitual.bedtime.date(on: wake, calendar: calendar)
        while bedtime < earliest {
            bedtime = calendar.date(byAdding: .day, value: 1, to: bedtime) ?? earliest
        }
        return bedtime
    }
}
