/// Where the Watch's wake-window session is in its life.
public enum WristSessionState: String, Codable, Sendable, Equatable {
    case idle
    case scheduled
    case running
    case alerting
    case ended

    /// A new window may be armed only when no session is pending or live.
    public var canArm: Bool {
        switch self {
        case .idle, .ended: true
        case .scheduled, .running, .alerting: false
        }
    }
}
