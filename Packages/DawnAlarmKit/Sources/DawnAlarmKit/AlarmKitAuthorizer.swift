#if canImport(AlarmKit)
import AlarmKit

/// Asks AlarmKit for permission to schedule alarms.
public struct AlarmKitAuthorizer: AlarmAuthorizing {
    public init() {}

    public func state() async -> AlarmPermissionState {
        Self.map(AlarmManager.shared.authorizationState)
    }

    public func request() async -> AlarmPermissionState {
        guard let answer = try? await AlarmManager.shared.requestAuthorization() else { return .denied }
        return Self.map(answer)
    }

    private static func map(_ state: AlarmManager.AuthorizationState) -> AlarmPermissionState {
        switch state {
        case .notDetermined: .notDetermined
        case .authorized: .authorized
        case .denied: .denied
        @unknown default: .denied
        }
    }
}
#endif
