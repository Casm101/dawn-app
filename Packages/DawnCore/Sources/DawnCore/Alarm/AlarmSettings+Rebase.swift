import Foundation

extension AlarmSettings {
    /// These settings, an edit of `original`, laid over `current`: each setting the user changed
    /// comes from here and every other one from `current`, so a change that arrived from the other
    /// device while the editor was open is not undone. With no current copy, as after the alarm was
    /// deleted elsewhere, the edit stands as it is and brings the alarm back.
    public func rebased(from original: AlarmSettings, onto current: AlarmSettings?) -> AlarmSettings {
        guard var result = current else { return self }
        if isEnabled != original.isEnabled { result.isEnabled = isEnabled }
        if time != original.time { result.time = time }
        if repeatDays != original.repeatDays { result.repeatDays = repeatDays }
        if sound != original.sound { result.sound = sound }
        if snoozeMinutes != original.snoozeMinutes { result.snoozeMinutes = snoozeMinutes }
        if windowMinutes != original.windowMinutes { result.windowMinutes = windowMinutes }
        return result
    }
}
