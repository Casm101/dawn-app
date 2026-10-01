import Foundation

/// Time spent in each stage over one session.
public struct StageTotals: Hashable, Codable, Sendable {
    public let awake: TimeInterval
    public let rem: TimeInterval
    public let core: TimeInterval
    public let deep: TimeInterval
    /// Asleep with no stage recorded, so the stages always add up to the session's time asleep.
    public let unspecified: TimeInterval

    public init(
        awake: TimeInterval, rem: TimeInterval, core: TimeInterval, deep: TimeInterval, unspecified: TimeInterval = 0
    ) {
        self.awake = awake
        self.rem = rem
        self.core = core
        self.deep = deep
        self.unspecified = unspecified
    }

    /// Totals for a session's samples, or nil when none of them carries a stage.
    init?(samples: [SleepSample], awake: TimeInterval) {
        guard samples.contains(where: \.stage.isStaged) else { return nil }
        func total(_ stage: SleepStage) -> TimeInterval {
            samples.filter { $0.stage == stage }.reduce(0) { $0 + $1.duration }
        }
        self.init(
            awake: awake, rem: total(.rem), core: total(.core), deep: total(.deep), unspecified: total(.unspecified)
        )
    }
}
