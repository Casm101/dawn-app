/// Whether the user has answered the Health read prompt for sleep.
public enum HealthAccessState: Sendable, Equatable {
    case notDetermined
    /// The prompt has been answered. Health never says whether reading was refused, so a refusal
    /// looks the same and simply returns no samples.
    case granted
    case denied
    case unavailable
}
