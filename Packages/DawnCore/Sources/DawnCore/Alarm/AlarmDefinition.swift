import Foundation

/// One alarm as the user set it. Ticket 09 syncs this between the phone and the Watch.
public struct AlarmDefinition: Codable, Sendable, Identifiable, Hashable {
    public let id: UUID
    public var isEnabled: Bool
    /// When it rings; on the Watch, the end of the wake window.
    public var time: ClockTime
    /// Empty means once, at the next occurrence of `time`.
    public var repeatDays: Set<Weekday>
    public var sound: AlarmSound
    public var snoozeMinutes: Int
    public var windowMinutes: Int
    public var updatedAt: Date

    public init(
        id: UUID = UUID(),
        isEnabled: Bool = true,
        time: ClockTime,
        repeatDays: Set<Weekday> = Weekday.weekdays,
        sound: AlarmSound = .chimes,
        snoozeMinutes: Int = Tuning.Alarm.defaultSnoozeMinutes,
        windowMinutes: Int = Tuning.Alarm.defaultWindowMinutes,
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.isEnabled = isEnabled
        self.time = time
        self.repeatDays = repeatDays
        self.sound = sound
        self.snoozeMinutes = Tuning.Alarm.snoozeMinutes.clamped(snoozeMinutes)
        self.windowMinutes = Tuning.Alarm.windowMinutes.clamped(windowMinutes)
        self.updatedAt = updatedAt
    }

    public var repeats: Bool { !repeatDays.isEmpty }
}
