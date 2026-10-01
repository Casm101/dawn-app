import DawnCore

/// Wrist motion as it arrives during the wake window. CoreMotion sits behind it on the Watch.
public protocol MotionStream: Sendable {
    /// Readings at about ten a second until `stop` is called; finishes at once without a sensor.
    func start() async -> AsyncStream<MotionSample>
    func stop() async
}
