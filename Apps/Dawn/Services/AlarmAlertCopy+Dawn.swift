import DawnAlarmKit
import Foundation

extension AlarmAlertCopy {
    /// The words on Dawn's system alarm.
    static let dawn = AlarmAlertCopy(
        title: LocalizedStringResource("alarm.alert.title", defaultValue: "Time to wake up"),
        stop: LocalizedStringResource("alarm.alert.stop", defaultValue: "Stop"),
        snooze: LocalizedStringResource("alarm.alert.snooze", defaultValue: "Snooze"),
        snoozing: LocalizedStringResource("alarm.alert.snoozing", defaultValue: "Snoozing")
    )
}
