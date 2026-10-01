/// Heart-rate readings as they arrive during the wake window. HealthKit sits behind it on the
/// Watch; without a workout session the readings are passive and may be minutes apart.
public protocol HeartRateStream: Sendable {
    /// Asks to read heart rate, showing the system prompt if it has never been answered. Only from
    /// the foreground. True when the question has been answered.
    func authorize() async -> Bool
    /// True once the question has been answered, without asking; reading after a refusal simply
    /// finds nothing.
    func canRead() async -> Bool
    /// Readings from a few minutes before now onward, until `stop` is called.
    func start() async -> AsyncStream<HeartRateSample>
    func stop() async
}
