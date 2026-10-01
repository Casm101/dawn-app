import DawnCore
import Foundation

/// One ring of an alarm stood down because the Watch woke the wearer before it.
public struct BackstopSkip: Codable, Hashable, Sendable {
    /// The ring that must not sound.
    public let ring: Date
    public let weekday: Weekday
    /// The one-off alarm standing in for the same weekday a week later, for a repeating alarm.
    public let fixedID: UUID?

    public init(ring: Date, weekday: Weekday, fixedID: UUID?) {
        self.ring = ring
        self.weekday = weekday
        self.fixedID = fixedID
    }
}
