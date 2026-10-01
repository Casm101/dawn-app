import Foundation

/// One stretch of a night's timeline: asleep, or awake between two stretches of sleep.
public struct NightTimelineEntry: Hashable, Sendable, Identifiable {
    public let start: Date
    public let end: Date
    public let isAwake: Bool

    public init(start: Date, end: Date, isAwake: Bool) {
        self.start = start
        self.end = end
        self.isAwake = isAwake
    }

    public var id: Date { start }
    public var duration: TimeInterval { end.timeIntervalSince(start) }
}
