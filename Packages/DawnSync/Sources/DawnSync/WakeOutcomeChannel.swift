import DawnCore

/// How a wake window's outcome reaches the phone: live while the phone can be woken, queued
/// otherwise, and de-duplicated by its id on arrival.
public protocol WakeOutcomeChannel: Sendable {
    /// Sends the outcome; a failed live delivery falls back to the queue.
    func send(_ outcome: WakeOutcome)
    /// Outcomes from the other device, in the order they arrive.
    var outcomes: AsyncStream<WakeOutcome> { get }
}
