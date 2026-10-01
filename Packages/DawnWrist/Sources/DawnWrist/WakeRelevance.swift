#if os(watchOS)
import AppIntents
import Foundation

/// Tells the system when the "Arm tonight" widget belongs in the Smart Stack: from the bedtime
/// nudge until the window starts, and only while that window is not armed.
public enum WakeRelevance {
    public static let widgetKind = "ArmTonight"

    public static func update(nudge: Date?, windowStart: Date?) async {
        guard let nudge, let windowStart, nudge < windowStart else {
            try? await RelevantIntentManager.shared.updateRelevantIntents([])
            return
        }
        let relevant = RelevantIntent(
            ArmTonightConfiguration(), widgetKind: widgetKind, relevance: RelevantContext.date(from: nudge, to: windowStart)
        )
        try? await RelevantIntentManager.shared.updateRelevantIntents([relevant])
    }
}
#endif
