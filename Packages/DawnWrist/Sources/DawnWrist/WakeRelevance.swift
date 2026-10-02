#if os(watchOS)
import AppIntents
import Foundation

/// Tells the system when the "Arm tonight" widget belongs in the Smart Stack: during `interval`,
/// which the coordinator gives only while the next window is not armed.
public enum WakeRelevance {
    public static let widgetKind = "ArmTonight"

    public static func update(during interval: DateInterval?) async {
        guard let interval else {
            try? await RelevantIntentManager.shared.updateRelevantIntents([])
            return
        }
        let relevant = RelevantIntent(
            ArmTonightConfiguration(), widgetKind: widgetKind, relevance: RelevantContext.date(from: interval.start, to: interval.end)
        )
        try? await RelevantIntentManager.shared.updateRelevantIntents([relevant])
    }
}
#endif
