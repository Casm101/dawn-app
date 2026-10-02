/// Why the window woke the wearer (WakeTF's trigger reasons, MIT, trimmed to the epoch rule).
public enum WakeTrigger: String, Hashable, Sendable, Codable {
    /// Movement above the threshold for two epochs in a row after the warm-up.
    case stirring
    /// The same, with heart rate taking part.
    case stirringWithHeartRate
    /// One movement large enough to wake on, after the start guard.
    case strongBurst
    /// Nothing woke them earlier, so the window's end minus the safety margin.
    case windowEnd
    /// The system was about to end the session.
    case sessionExpiring

    /// True when the wearer was woken before the end of the window.
    public var isEarly: Bool {
        switch self {
        case .stirring, .stirringWithHeartRate, .strongBurst: true
        case .windowEnd, .sessionExpiring: false
        }
    }
}
