import Foundation

/// Keeps the last forecast and works the curve out again only when the nights, the usual times or
/// the day it is for change, not every time a view asks.
public struct EnergyForecastCache: Sendable {
    private struct Key: Hashable {
        let sessions: [SleepSession]
        let usual: UsualSleep
        let anchors: EnergyAnchors
    }

    private var last: (key: Key, forecast: EnergyForecast)?
    /// How many forecasts have been worked out, for tests.
    public private(set) var computations = 0

    public init() {}

    public mutating func forecast(sessions: [SleepSession], usual: UsualSleep, now: Date, calendar: Calendar) -> EnergyForecast {
        let anchors = EnergyAnchors(sessions: sessions, usual: usual, now: now, calendar: calendar)
        let key = Key(sessions: sessions, usual: usual, anchors: anchors)
        if let last, last.key == key { return last.forecast }
        let forecast = EnergyForecast(anchors: anchors, sessions: sessions, calendar: calendar)
        last = (key, forecast)
        computations += 1
        return forecast
    }
}
