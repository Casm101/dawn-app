import Foundation

/// A stretch of sleep as the timeline draws it. An end cut off by the window edge is flagged, so it
/// is never shown as a real bedtime or wake.
public struct TimelineSegment: Hashable, Sendable, Identifiable {
    public let start: Date
    public let end: Date
    public let startsBeforeWindow: Bool
    public let endsAfterWindow: Bool

    public var id: Date { start }
}
