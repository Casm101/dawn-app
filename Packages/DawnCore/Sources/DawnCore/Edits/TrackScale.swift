import Foundation

/// Maps moments on the night editor's track to distances across it and back.
public struct TrackScale: Hashable, Sendable {
    public private(set) var span: DateInterval

    public init(span: DateInterval) {
        self.span = span
    }

    /// The distance across a track `width` wide at which `moment` sits.
    public func x(_ moment: Date, width: Double) -> Double {
        guard span.duration > 0 else { return 0 }
        return moment.timeIntervalSince(span.start) / span.duration * width
    }

    /// The moment at `x` across a track `width` wide, held to the track's ends.
    public func date(_ x: Double, width: Double) -> Date {
        guard width > 0 else { return span.start }
        return span.start.addingTimeInterval(min(max(x, 0), width) / width * span.duration)
    }

    /// Grows to take in `other`, and never shrinks, so the track does not move under a finger.
    public mutating func widen(to other: DateInterval) {
        span = DateInterval(start: min(span.start, other.start), end: max(span.end, other.end))
    }
}
