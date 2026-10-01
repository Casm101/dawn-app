import DawnCore

extension AlarmSettings {
    /// Whether the system alarm for these settings differs from the one for `other`. The wake window
    /// is the Watch's alone, so changing only the window leaves the system alarm where it is.
    func ringsDifferently(from other: AlarmSettings) -> Bool {
        isEnabled != other.isEnabled || time != other.time || repeatDays != other.repeatDays
            || sound != other.sound || snoozeMinutes != other.snoozeMinutes
    }
}
