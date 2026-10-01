import Foundation

/// The nights no alarm ended, which are the only ones sleep need learns from.
public enum AlarmFreeNights {
    /// Time asleep on each alarm-free night, oldest first.
    public static func asleep(in sessions: [SleepSession], alarms: [AlarmDefinition], calendar: Calendar) -> [TimeInterval] {
        sessions
            .filter { $0.kind == .night && !endedByAlarm($0, alarms: alarms, calendar: calendar) }
            .sorted { $0.end < $1.end }
            .map(\.asleep)
    }

    /// True when an alarm that was on when the night ended, and applies to its wake day, rings within
    /// `Tuning.Need.alarmWakeTolerance` of the wake. "On at the time" comes from the stamp on the
    /// switch, so a one-off alarm switched off after it rang still counts for the night it ended.
    static func endedByAlarm(_ night: SleepSession, alarms: [AlarmDefinition], calendar: Calendar) -> Bool {
        let weekday = calendar.component(.weekday, from: night.end)
        return alarms.contains { alarm in
            let settings = alarm.settings
            guard wasOn(alarm, at: night.end),
                  !settings.repeats || settings.repeatDays.contains(where: { $0.rawValue == weekday }) else { return false }
            let ring = settings.time.date(on: night.end, calendar: calendar)
            return abs(night.end.timeIntervalSince(ring)) <= Tuning.Need.alarmWakeTolerance
        }
    }

    /// An alarm on now was on at `moment` if it was switched on before it; one off now was on at
    /// `moment` if it was switched off after it.
    static func wasOn(_ alarm: AlarmDefinition, at moment: Date) -> Bool {
        alarm.enabled.value ? alarm.enabled.updatedAt <= moment : alarm.enabled.updatedAt > moment
    }
}
