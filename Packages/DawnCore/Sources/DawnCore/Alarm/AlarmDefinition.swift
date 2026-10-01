import Foundation

/// One alarm as stored and synced: every setting carries its own stamp, so edits made on the phone
/// and on the Watch while apart can be merged field by field.
public struct AlarmDefinition: Codable, Sendable, Identifiable, Hashable {
    public let id: UUID
    public private(set) var enabled: Stamped<Bool>
    public private(set) var wakeTime: Stamped<ClockTime>
    public private(set) var repeatDays: Stamped<Set<Weekday>>
    public private(set) var sound: Stamped<AlarmSound>
    public private(set) var snoozeMinutes: Stamped<Int>
    public private(set) var windowMinutes: Stamped<Int>

    public init(id: UUID = UUID(), settings: AlarmSettings, at now: Date, by origin: Replica) {
        self.id = id
        enabled = Stamped(settings.isEnabled, at: now, by: origin)
        wakeTime = Stamped(settings.time, at: now, by: origin)
        repeatDays = Stamped(settings.repeatDays, at: now, by: origin)
        sound = Stamped(settings.sound, at: now, by: origin)
        snoozeMinutes = Stamped(settings.snoozeMinutes, at: now, by: origin)
        windowMinutes = Stamped(settings.windowMinutes, at: now, by: origin)
    }

    public var settings: AlarmSettings {
        AlarmSettings(
            isEnabled: enabled.value, time: wakeTime.value, repeatDays: repeatDays.value,
            sound: sound.value, snoozeMinutes: snoozeMinutes.value, windowMinutes: windowMinutes.value
        )
    }

    /// Takes the new settings, restamping only the fields that changed.
    public mutating func apply(_ settings: AlarmSettings, at now: Date, by origin: Replica) {
        enabled = enabled.setting(settings.isEnabled, at: now, by: origin)
        wakeTime = wakeTime.setting(settings.time, at: now, by: origin)
        repeatDays = repeatDays.setting(settings.repeatDays, at: now, by: origin)
        sound = sound.setting(settings.sound, at: now, by: origin)
        snoozeMinutes = snoozeMinutes.setting(settings.snoozeMinutes, at: now, by: origin)
        windowMinutes = windowMinutes.setting(settings.windowMinutes, at: now, by: origin)
    }
}
