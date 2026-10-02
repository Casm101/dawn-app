import AppIntents
import DawnUI
import DawnWrist
import SwiftUI
import WidgetKit

/// The Smart Stack card that asks to arm tonight's window. The Watch app makes it relevant only while
/// the window is unarmed; tapping it opens the app, which arms on opening.
struct ArmTonightWidget: Widget {
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: WakeRelevance.widgetKind, intent: ArmTonightConfiguration.self, provider: ArmTonightProvider()) { _ in
            VStack(alignment: .leading, spacing: DawnSpacing.xs) {
                Label(String(localized: "widget.arm.title", defaultValue: "Arm tonight"), systemImage: "alarm")
                    .font(DawnFont.title)
                Text(String(localized: "widget.arm.body", defaultValue: "Tap to let your Watch wake you gently."))
                    .font(DawnFont.caption)
            }
            .containerBackground(.background, for: .widget)
        }
        .configurationDisplayName(String(localized: "widget.arm.name", defaultValue: "Arm tonight"))
        .description(String(localized: "widget.arm.description", defaultValue: "Shows at bedtime when tonight's wake window is not armed."))
        .supportedFamilies([.accessoryRectangular])
    }
}
