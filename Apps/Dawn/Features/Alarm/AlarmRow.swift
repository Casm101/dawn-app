import DawnCore
import DawnUI
import SwiftUI

/// One alarm in the list: its time, its days and its switch.
struct AlarmRow: View {
    @Environment(AlarmStore.self) private var store
    let alarm: AlarmDefinition

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: DawnSpacing.xs) {
                Text(AlarmText.time(alarm.time))
                    .font(DawnFont.metric)
                    .monospacedDigit()
                Text(AlarmText.days(alarm.repeatDays))
                    .font(DawnFont.caption)
                    .foregroundStyle(DawnColor.secondaryText)
            }
            .foregroundStyle(alarm.isEnabled ? .primary : DawnColor.secondaryText)
            Spacer()
            Toggle(isOn: Binding(
                get: { alarm.isEnabled },
                set: { on in Task { await store.setEnabled(on, for: alarm.id) } }
            )) {
                Text(AlarmText.time(alarm.time))
            }
            .labelsHidden()
        }
        .accessibilityElement(children: .contain)
    }
}
