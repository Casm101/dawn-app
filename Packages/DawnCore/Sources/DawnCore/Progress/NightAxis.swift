import Foundation

/// The vertical axis of the Sleep Times chart, in wall-clock hours after noon on each night's evening
/// day, so a night from 23:00 to 07:00 runs from 11 to 19 without breaking at midnight, and a clock
/// change during the night does not shift it against the hour labels.
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

    /// Where a moment sits on the axis for a night that began on `evening`, by the clock on the wall.
    public static func offset(_ date: Date, evening: Date, calendar: Calendar) -> Double {
        let days = calendar.dateComponents([.day], from: calendar.startOfDay(for: evening), to: calendar.startOfDay(for: date)).day ?? 0
        let clock = calendar.dateComponents([.hour, .minute, .second], from: date)
        let hours = Double(clock.hour ?? 0) + Double(clock.minute ?? 0) / 60 + Double(clock.second ?? 0) / 3600
        return Double(days * 24) + hours - 12
    }

    /// The wall-clock hour of day, 0 to 23, at an axis value.
    public static func hourOfDay(_ value: Double) -> Int {
        ((Int(value.rounded(.down)) + 12) % 24 + 24) % 24
    }

    /// The fraction of the axis height from the top, clamped to the axis.
    public func position(_ date: Date, evening: Date, calendar: Calendar) -> Double {
        min(1, max(0, (Self.offset(date, evening: evening, calendar: calendar) - lower) / span))
    }
}
