/// Whether the user has let Dawn schedule system alarms.
public enum AlarmPermissionState: Sendable, Equatable {
    case notDetermined
    case authorized
    case denied
}
