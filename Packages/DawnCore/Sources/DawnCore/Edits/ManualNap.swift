import Foundation

/// A nap the user added by hand.
public struct ManualNap: Hashable, Sendable, Codable, Identifiable {
    public let id: UUID
    public let start: Date
    public let end: Date

    public init(id: UUID = UUID(), start: Date, end: Date) {
        self.id = id
        self.start = start
        self.end = end
    }

    public var session: SleepSession {
        SleepSession(
            kind: .nap, source: Tuning.Edits.source,
            samples: [SleepSample(start: start, end: end, stage: .unspecified, source: Tuning.Edits.source)]
        )
    }
}
