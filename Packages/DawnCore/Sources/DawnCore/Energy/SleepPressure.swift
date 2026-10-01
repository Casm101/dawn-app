import Foundation

/// Homeostatic pressure S at a waking, carried through the sleep that led up to it.
public enum SleepPressure {
    /// Starts from the habitual schedule's steady state and runs through every recorded sleep in the
    /// habitual window. A waking no recorded sleep ends at is taken to follow a habitual night.
    public static func atWake(_ wake: Date, sessions: [SleepSession], habitual: HabitualSleep) -> Double {
        let night = habitual.nightLength
        let steady = AlertnessModel.steadyPressure(sleep: night, wake: 24 * 3600 - night)
        let since = wake.addingTimeInterval(-Tuning.Energy.habitualWindow)
        var periods = sessions.filter { $0.end <= wake && $0.end > since }.map { DateInterval(start: $0.start, end: $0.end) }
        if !periods.contains(where: { abs($0.end.timeIntervalSince(wake)) < Tuning.Energy.gridStep }) {
            periods.append(DateInterval(start: wake.addingTimeInterval(-night), end: wake))
        }
        periods.sort { $0.start < $1.start }
        guard let first = periods.first else { return steady.atWake }
        var pressure = steady.atSleep
        var clock = first.start
        for period in periods {
            if period.start > clock {
                pressure = AlertnessModel.pressure(afterWaking: period.start.timeIntervalSince(clock) / 3600, from: pressure)
            }
            let asleepFrom = max(period.start, clock)
            if period.end > asleepFrom {
                pressure = AlertnessModel.pressure(afterSleeping: period.end.timeIntervalSince(asleepFrom) / 3600, from: pressure)
            }
            clock = max(clock, period.end)
        }
        return pressure
    }
}
