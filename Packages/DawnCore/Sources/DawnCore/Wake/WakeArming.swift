import Foundation

/// What the Watch has armed and what it last woke for, saved so a relaunch at the window's start
/// knows its plan and opening the app after a wake arms the following night.
public struct WakeArming: Hashable, Sendable, Codable {
    /// The window a session is scheduled or running for.
    public var armed: WakePlan?
    /// The ring of the last window that woke the wearer.
    public var completedRing: Date?

    public init(armed: WakePlan? = nil, completedRing: Date? = nil) {
        self.armed = armed
        self.completedRing = completedRing
    }

    /// The window that should be armed now: the plan, unless it is the one already armed.
    public func toArm(_ plan: WakePlan?, sessionPending: Bool) -> WakePlan? {
        guard let plan else { return nil }
        return plan == armed && sessionPending ? nil : plan
    }

    /// After the window fired and ended: nothing armed, and that ring done.
    public mutating func woke() {
        completedRing = armed?.windowEnd ?? completedRing
        armed = nil
    }

    /// After the session ended without waking anyone: nothing armed, the ring left open to re-arm.
    public mutating func ended() {
        armed = nil
    }
}
