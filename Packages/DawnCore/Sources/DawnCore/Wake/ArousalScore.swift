/// How much one epoch looks like stirring, from 0 to 1.
public struct ArousalScore: Hashable, Sendable {
    public let motion: Double
    public let heartRate: Double
    public let combined: Double
    /// True when heart rate was fresh and took part in `combined`.
    public let usedHeartRate: Bool
    /// True when a single movement was large enough to wake on its own.
    public let isStrongBurst: Bool
}
