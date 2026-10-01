import Foundation

/// The three-process model of alertness: homeostatic pressure S, the circadian C and ultradian U
/// rhythms, and sleep inertia W, added together. Higher is more alert.
public enum AlertnessModel {
    private typealias T = Tuning.Energy

    /// S after `hours` awake, from `start` at waking.
    public static func pressure(afterWaking hours: Double, from start: Double) -> Double {
        T.lowerAsymptote + (start - T.lowerAsymptote) * exp(-T.wakeDecay * hours)
    }

    /// S after `hours` asleep, from `start` at falling asleep: in a straight line up to the brake
    /// level, then exponentially toward the upper asymptote.
    public static func pressure(afterSleeping hours: Double, from start: Double) -> Double {
        let rate = T.sleepRecovery * (T.upperAsymptote - T.brakeLevel)
        let braked = start < T.brakeLevel ? (T.brakeLevel - start) / rate : 0
        guard hours > braked else { return start + hours * rate }
        let from = max(start, T.brakeLevel)
        return T.upperAsymptote - (T.upperAsymptote - from) * exp(-T.sleepRecovery * (hours - braked))
    }

    /// C plus U at `hour` of the day (0 to 24), for a circadian rhythm peaking at `peakHour`; U
    /// peaks `ultradianLag` hours later, and so bottoms out that long before.
    public static func rhythm(atHour hour: Double, peakHour: Double) -> Double {
        let circadian = T.circadianMesor + T.circadianAmplitude * cos(2 * .pi * (hour - peakHour) / 24)
        let ultradian = T.ultradianMesor + T.ultradianAmplitude * cos(2 * .pi * (hour - peakHour - T.ultradianLag) / 12)
        return circadian + ultradian
    }

    /// W after `hours` awake.
    public static func inertia(afterWaking hours: Double) -> Double {
        T.inertiaStart * exp(T.inertiaRecovery * hours)
    }

    /// How long inertia takes to rise above `level`.
    public static func inertiaLasts(until level: Double) -> TimeInterval {
        log(level / T.inertiaStart) / T.inertiaRecovery * 3600
    }

    /// S at waking and at falling asleep for someone who sleeps `sleep` and is awake `wake` every
    /// day, found by running the schedule until it settles.
    public static func steadyPressure(sleep: TimeInterval, wake: TimeInterval) -> (atWake: Double, atSleep: Double) {
        var atWake = T.upperAsymptote
        var atSleep = T.lowerAsymptote
        for _ in 0..<50 {
            atSleep = pressure(afterWaking: wake / 3600, from: atWake)
            atWake = pressure(afterSleeping: sleep / 3600, from: atSleep)
        }
        return (atWake, atSleep)
    }
}
