import DawnAlarmKit
import DawnCore
import DawnUI
import SwiftUI

/// One alarm in the list: its time, its days and its switch.
struct AlarmRow: View {
    @Environment(AlarmLibrary.self) private var library
    let alarm: AlarmDefinition

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: DawnSpacing.xs) {
                Text(AlarmText.time(settings.time))
                    .font(DawnFont.metric)
                    .monospacedDigit()
                Text(AlarmText.days(settings.repeatDays))
                    .font(DawnFont.caption)
                    .foregroundStyle(DawnColor.secondaryText)
            }
            .foregroundStyle(settings.isEnabled ? .primary : DawnColor.secondaryText)
            Spacer()
            Toggle(isOn: Binding(
                get: { settings.isEnabled },
                set: { on in Task { await library.setEnabled(on, for: alarm.id) } }
            )) {
                Text(AlarmText.time(settings.time))
            }
            .labelsHidden()
        }
        .accessibilityElement(children: .contain)
    }

    private var settings: AlarmSettings { alarm.settings }
}
