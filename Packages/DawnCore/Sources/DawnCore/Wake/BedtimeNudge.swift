import Foundation

/// The one reminder to arm tonight's window: due a fixed lead before the ring, and only while
/// nothing is armed for that ring.
public enum BedtimeNudge {
    /// When to nudge, or nil when the window is armed, there is nothing to arm, or the time has passed.
    public static func date(for plan: WakePlan?, armedRing: Date?, now: Date) -> Date? {
        guard let plan, armedRing != plan.windowEnd else { return nil }
        let nudge = plan.windowEnd.addingTimeInterval(-Tuning.Wake.nudgeLead)
        return nudge > now ? nudge : nil
    }

    /// True when the reminder and the Smart Stack widget should be offered for this plan.
    public static func isNeeded(for plan: WakePlan?, armedRing: Date?) -> Bool {
        guard let plan else { return false }
        return armedRing != plan.windowEnd
    }
}
