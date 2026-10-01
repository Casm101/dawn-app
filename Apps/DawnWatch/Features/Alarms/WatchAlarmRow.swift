import DawnCore
import DawnUI
import SwiftUI

/// An alarm's time, its wake window and its switch.
struct WatchAlarmRow: View {
    @Environment(WatchAlarmStore.self) private var alarms
    let alarm: AlarmDefinition

    var body: some View {
        Toggle(isOn: Binding(get: { alarm.settings.isEnabled }, set: { on in
            var settings = alarm.settings
            settings.isEnabled = on
            alarms.save(settings, id: alarm.id)
        })) {
            VStack(alignment: .leading) {
                Text(alarm.settings.time.date(on: Date(), calendar: .current).formatted(date: .omitted, time: .shortened))
                    .font(DawnFont.title)
                    .monospacedDigit()
                Text(String(localized: "watch.alarm.window", defaultValue: "\(alarm.settings.windowMinutes) min window"))
                    .font(DawnFont.caption)
                    .foregroundStyle(DawnColor.secondaryText)
            }
        }
    }
}
