import Foundation

/// A mark down the side of the timeline: every quarter hour, with a label on the hour.
public struct TimelineTick: Hashable, Sendable {
    public let date: Date
    public let isHour: Bool
}
