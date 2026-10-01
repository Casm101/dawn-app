import DawnCore
import Foundation
import Observation

/// Hands views the day's energy forecast, working the curve out again only when a night, the usual
/// times or the day changes. Views ask for it while drawing, so the cache is not observed.
@MainActor
@Observable
final class EnergyForecaster {
    @ObservationIgnored private var cache = EnergyForecastCache()

    func forecast(sessions: [SleepSession], usual: UsualSleep, now: Date) -> EnergyForecast {
        cache.forecast(sessions: sessions, usual: usual, now: now, calendar: .current)
    }
}
