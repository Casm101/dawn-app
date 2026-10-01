/// The alarm permission boundary. AlarmKit sits behind it on iOS; tests use a fake.
public protocol AlarmAuthorizing: Sendable {
    func state() async -> AlarmPermissionState
    /// Shows the system prompt the first time; afterwards returns the stored answer.
    func request() async -> AlarmPermissionState
}
