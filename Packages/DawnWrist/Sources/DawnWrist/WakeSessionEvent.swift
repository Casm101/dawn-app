import Foundation

/// What the system says about the wake-window session.
public enum WakeSessionEvent: Sendable, Equatable {
    /// The window has begun; the system ends the session at `expires`.
    case started(expires: Date?)
    /// The system is about to end the session.
    case willExpire
    /// The session is over: after Stop, at its end, or because the system ended it.
    case ended(failed: Bool)
}
