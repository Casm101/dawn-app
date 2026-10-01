import Foundation

/// One stretch of sleep or wakefulness as a source recorded it.
public struct SleepSample: Hashable, Codable, Sendable {
    public let start: Date
    public let end: Date
    public let stage: SleepStage
    /// The name of the app or device that recorded the sample.
    public let source: String

    public init(start: Date, end: Date, stage: SleepStage, source: String) {
        self.start = start
        self.end = end
        self.stage = stage
        self.source = source
    }

    public var duration: TimeInterval { end.timeIntervalSince(start) }
}
