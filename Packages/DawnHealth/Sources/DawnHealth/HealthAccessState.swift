/// Whether the user has answered the Health read prompt for sleep.
public enum HealthAccessState: Sendable, Equatable {
    case notDetermined
    case granted
    case denied
    case unavailable
}
