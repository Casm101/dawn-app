import Foundation

/// One column of the Sleep Times chart: an evening and the nights that began on it.
public struct NightSlot: Hashable, Sendable, Identifiable {
    /// Midnight at the start of the evening's day.
    public let evening: Date
    /// Night sessions that began that evening, in order. Empty when Health has none.
    public let nights: [SleepSession]
    public let isTonight: Bool
    /// How the night is named, decided with the same tonight as `isTonight`.
    public let label: NightLabel

    public var id: Date { evening }
    public var segments: [SleepSegment] { nights.flatMap(\.segments) }
    public var asleep: TimeInterval { nights.reduce(0) { $0 + $1.asleep } }
}
