import Foundation

/// The nights no alarm ended, which are the only ones sleep need learns from.
public enum AlarmFreeNights {
    /// Time asleep on each alarm-free night, oldest first.
    public static func asleep(in sessions: [SleepSession], alarms: [AlarmSettings], calendar: Calendar) -> [TimeInterval] {
        sessions
            .filter { $0.kind == .night && !endedByAlarm($0, alarms: alarms, calendar: calendar) }
            .sorted { $0.end < $1.end }
            .map(\.asleep)
    }

    /// True when an enabled alarm for the wake day rings within `Tuning.Need.alarmWakeTolerance` of the wake.
    static func endedByAlarm(_ night: SleepSession, alarms: [AlarmSettings], calendar: Calendar) -> Bool {
        let weekday = calendar.component(.weekday, from: night.end)
        return alarms.contains { alarm in
            guard alarm.isEnabled, !alarm.repeats || alarm.repeatDays.contains(where: { $0.rawValue == weekday }) else {
                return false
            }
            let ring = alarm.time.date(on: night.end, calendar: calendar)
            return abs(night.end.timeIntervalSince(ring)) <= Tuning.Need.alarmWakeTolerance
        }
    }
}
