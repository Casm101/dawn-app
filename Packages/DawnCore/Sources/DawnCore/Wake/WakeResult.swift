/// How a night's wake window ended.
public enum WakeResult: String, Hashable, Sendable, Codable {
    /// The Watch woke the wearer before the window ended, so the phone's alarm was stood down.
    case wokeEarly
    /// The Watch woke the wearer at the end of the window, with the phone's alarm.
    case wokeAtEnd
    /// The session ended before it could wake anyone; the phone's alarm rang.
    case sessionEnded
}
