import DawnCore
import DawnUI
import SwiftUI

/// An alarm's time and wake window, which open its editor, and beside them its switch, which turns
/// it on or off where it is. The link covers only the text, so the switch is never part of it.
struct WatchAlarmRow: View {
    @Environment(WatchAlarmStore.self) private var alarms
    let alarm: AlarmDefinition

    var body: some View {
        HStack {
            NavigationLink(value: alarm) {
                VStack(alignment: .leading) {
                    Text(alarm.settings.time.date(on: Date(), calendar: .current).formatted(date: .omitted, time: .shortened))
                        .font(DawnFont.title)
                        .monospacedDigit()
                    Text(String(localized: "watch.alarm.window", defaultValue: "\(alarm.settings.windowMinutes) min window"))
                        .font(DawnFont.caption)
                        .foregroundStyle(DawnColor.secondaryText)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.plain)
            Toggle(String(localized: "watch.alarm.on", defaultValue: "On"), isOn: Binding(get: { alarm.settings.isEnabled }, set: { on in
                var settings = alarm.settings
                settings.isEnabled = on
                alarms.save(settings, id: alarm.id)
            }))
            .labelsHidden()
            .fixedSize()
            .accessibilityIdentifier("alarm-switch")
        }
    }
}
