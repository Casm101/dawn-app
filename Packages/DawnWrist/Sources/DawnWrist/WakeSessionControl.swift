import Foundation

/// The smart-alarm session the coordinator schedules and wakes through. WatchKit sits behind it
/// on the Watch; tests use a fake.
@MainActor
public protocol WakeSessionControl: AnyObject {
    /// News from the current session only.
    var events: AsyncStream<WakeSessionEvent> { get }
    /// True while a session from this launch is waiting for its start or running.
    var isPending: Bool { get }
    /// Schedules a session for `date` once any earlier one has finished ending. Foreground only.
    func schedule(at date: Date) async
    /// Plays the wake haptic again and again until Stop.
    func wake()
    func cancel()
}
