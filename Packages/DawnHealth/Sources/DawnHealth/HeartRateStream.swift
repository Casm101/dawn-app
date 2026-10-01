import DawnCore

/// Heart-rate readings as they arrive during the wake window. HealthKit sits behind it on the
/// Watch; without a workout session the readings are passive and may be minutes apart.
public protocol HeartRateStream: Sendable {
    /// Asks to read heart rate; true when allowed.
    func authorize() async -> Bool
    /// Readings from a few minutes before now onward, until `stop` is called.
    func start() async -> AsyncStream<HeartRateSample>
    func stop() async
}
