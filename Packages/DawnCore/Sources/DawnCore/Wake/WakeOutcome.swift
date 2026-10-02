import Foundation

/// What one night's wake window did: when it fired, why, and which sensors it had. Only these
/// aggregates are kept and sent to the phone, never the samples.
public struct WakeOutcome: Hashable, Sendable, Codable, Identifiable {
    public let id: UUID
    public let alarmID: UUID
    public let windowStart: Date
    /// The alarm's ring, where the phone's alarm stands.
    public let windowEnd: Date
    public var result: WakeResult
    public var firedAt: Date?
    public var trigger: WakeTrigger?
    public var usedMotion: Bool
    public var usedHeartRate: Bool
    public var epochs: Int
    public var peakScore: Double
    public var heartRateSamples: Int

    public init(
        id: UUID = UUID(), alarmID: UUID, windowStart: Date, windowEnd: Date, result: WakeResult,
        firedAt: Date? = nil, trigger: WakeTrigger? = nil, usedMotion: Bool = false, usedHeartRate: Bool = false,
        epochs: Int = 0, peakScore: Double = 0, heartRateSamples: Int = 0
    ) {
        self.id = id
        self.alarmID = alarmID
        self.windowStart = windowStart
        self.windowEnd = windowEnd
        self.result = result
        self.firedAt = firedAt
        self.trigger = trigger
        self.usedMotion = usedMotion
        self.usedHeartRate = usedHeartRate
        self.epochs = epochs
        self.peakScore = peakScore
        self.heartRateSamples = heartRateSamples
    }

    /// True while the phone's alarm for this window can still be stood down.
    public func standsDownBackstop(at now: Date) -> Bool {
        result == .wokeEarly && now < windowEnd
    }
}
