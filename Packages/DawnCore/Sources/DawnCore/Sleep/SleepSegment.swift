import Foundation

/// An unbroken stretch of sleep inside a session. Segments are separated by awake time, whether
/// recorded as awake or simply not covered by any sample.
public struct SleepSegment: Hashable, Sendable, Identifiable {
    public let start: Date
    public let end: Date
    /// The asleep samples inside the segment, in order, so the stage rail can draw them.
    public let samples: [SleepSample]

    public var id: Date { start }
    public var duration: TimeInterval { end.timeIntervalSince(start) }
}
