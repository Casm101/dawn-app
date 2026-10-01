/// The Health authorisation boundary. The HealthKit-backed implementation lives behind this
/// protocol so the rest of the app, and the tests, never import HealthKit.
public protocol HealthAccess: Sendable {
    func state() async -> HealthAccessState
    func requestSleepRead() async -> HealthAccessState
}
