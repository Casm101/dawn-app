import Foundation

/// What the user chooses for one alarm, without any record of when each part was chosen.
public struct AlarmSettings: Hashable, Sendable {
    public var isEnabled: Bool
    /// When it rings; on the Watch, the end of the wake window.
    public var time: ClockTime
    /// Empty means once, at the next occurrence of `time`.
    public var repeatDays: Set<Weekday>
    public var sound: AlarmSound
    public var snoozeMinutes: Int
    public var windowMinutes: Int

    public init(
        isEnabled: Bool = true,
        time: ClockTime,
        repeatDays: Set<Weekday> = Weekday.weekdays,
        sound: AlarmSound = .chimes,
        snoozeMinutes: Int = Tuning.Alarm.defaultSnoozeMinutes,
        windowMinutes: Int = Tuning.Alarm.defaultWindowMinutes
    ) {
        self.isEnabled = isEnabled
        self.time = time
        self.repeatDays = repeatDays
        self.sound = sound
        self.snoozeMinutes = Tuning.Alarm.snoozeMinutes.clamped(snoozeMinutes)
        self.windowMinutes = Tuning.Alarm.windowMinutes.clamped(windowMinutes)
    }

    public var repeats: Bool { !repeatDays.isEmpty }
}
