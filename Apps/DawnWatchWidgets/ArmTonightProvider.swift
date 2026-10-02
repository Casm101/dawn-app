import AppIntents
import DawnWrist
import WidgetKit

/// One unchanging entry: the card says the same thing whenever the system shows it.
struct ArmTonightProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> ArmTonightEntry { ArmTonightEntry(date: .now) }

    func snapshot(for configuration: ArmTonightConfiguration, in context: Context) async -> ArmTonightEntry {
        ArmTonightEntry(date: .now)
    }

    func timeline(for configuration: ArmTonightConfiguration, in context: Context) async -> Timeline<ArmTonightEntry> {
        Timeline(entries: [ArmTonightEntry(date: .now)], policy: .never)
    }

    /// The one ready-made card a Watch offers when adding widgets.
    func recommendations() -> [AppIntentRecommendation<ArmTonightConfiguration>] {
        [AppIntentRecommendation(intent: ArmTonightConfiguration(), description: LocalizedStringResource("widget.arm.name", defaultValue: "Arm tonight"))]
    }
}
