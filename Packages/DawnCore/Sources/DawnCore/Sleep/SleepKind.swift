import Foundation

/// Whether a session is the main sleep of a night or a daytime nap.
public enum SleepKind: String, Codable, Sendable {
    case night
    case nap

    /// A nap is a session shorter than `Tuning.Sleep.napMaxSpan` that starts after the day begins and
    /// ends before the evening, both in local time.
    public init(start: Date, end: Date, calendar: Calendar) {
        let isShort = end.timeIntervalSince(start) < Tuning.Sleep.napMaxSpan
        let startsInDaytime = calendar.component(.hour, from: start) >= Tuning.Sleep.daytimeStartHour
        let evening = calendar.date(
            bySettingHour: Tuning.Sleep.eveningStartHour, minute: 0, second: 0, of: start
        ) ?? start
        self = isShort && startsInDaytime && end <= evening ? .nap : .night
    }
}
