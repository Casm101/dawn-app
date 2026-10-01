import Foundation

/// The vertical axis of the Sleep Times chart, in hours after noon on each night's evening day, so a
/// night from 23:00 to 07:00 runs from 11 to 19 without breaking at midnight.
public struct NightAxis: Hashable, Sendable {
    public let lower: Double
    public let upper: Double

    /// Whole hours covering every segment on the page, and at least `Tuning.Progress.defaultAxis`.
    public init(slots: [NightSlot], calendar: Calendar) {
        var lower = Tuning.Progress.defaultAxis.lowerBound
        var upper = Tuning.Progress.defaultAxis.upperBound
        for slot in slots {
            for segment in slot.segments {
                lower = min(lower, Self.offset(segment.start, evening: slot.evening, calendar: calendar).rounded(.down))
                upper = max(upper, Self.offset(segment.end, evening: slot.evening, calendar: calendar).rounded(.up))
            }
        }
        self.lower = lower
        self.upper = upper
    }

    public var span: Double { upper - lower }

    /// Where a moment sits on the axis for a night that began on `evening`.
    public static func offset(_ date: Date, evening: Date, calendar: Calendar) -> Double {
        let noon = calendar.date(bySettingHour: 12, minute: 0, second: 0, of: evening) ?? evening
        return date.timeIntervalSince(noon) / 3600
    }

    /// The fraction of the axis height from the top, clamped to the axis.
    public func position(_ date: Date, evening: Date, calendar: Calendar) -> Double {
        min(1, max(0, (Self.offset(date, evening: evening, calendar: calendar) - lower) / span))
    }
}
