import Foundation

/// A night or a nap: one source's samples, without overlaps, from falling asleep to the final wake.
public struct SleepSession: Hashable, Codable, Sendable, Identifiable {
    public let kind: SleepKind
    public let source: String
    /// Time-ordered, non-overlapping samples. The first and last are asleep.
    public let samples: [SleepSample]
    public let start: Date
    public let end: Date

    public init(kind: SleepKind, source: String, samples: [SleepSample]) {
        self.kind = kind
        self.source = source
        self.samples = samples
        start = samples.first?.start ?? .distantPast
        end = samples.last?.end ?? .distantPast
    }

    public var id: Date { start }

    public var span: TimeInterval { end.timeIntervalSince(start) }

    public var asleep: TimeInterval {
        samples.filter(\.stage.isAsleep).reduce(0) { $0 + $1.duration }
    }

    /// Awake samples plus any stretch inside the session that no sample covers.
    public var awake: TimeInterval { max(0, span - asleep) }

    /// Nil when the samples carry no stages, so a missing breakdown is never shown as zero.
    public var stageTotals: StageTotals? { StageTotals(samples: samples, awake: awake) }
}
