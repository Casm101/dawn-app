import Foundation

/// The day's energy schedule as of a moment, the one Dawn gave a day earlier to compare with, and
/// the days either side that the timeline also draws.
public struct EnergyForecast: Hashable, Sendable {
    /// The day Home shows.
    public let today: EnergySchedule
    /// The day Home showed a day earlier.
    public let yesterday: EnergySchedule
    /// The day before the latest waking, that waking's day, and the next: everything the 24-hour
    /// timeline can meet.
    public let days: [EnergySchedule]

    public init(sessions: [SleepSession], usual: UsualSleep, now: Date, calendar: Calendar) {
        self.init(anchors: EnergyAnchors(sessions: sessions, usual: usual, now: now, calendar: calendar), sessions: sessions, calendar: calendar)
    }

    init(anchors: EnergyAnchors, sessions: [SleepSession], calendar: Calendar) {
        var built: [EnergyAnchor: EnergySchedule] = [:]
        func schedule(_ anchor: EnergyAnchor) -> EnergySchedule {
            if let known = built[anchor] { return known }
            let made = EnergySchedule(wake: anchor.wake, habitual: anchor.habitual, sessions: sessions, calendar: calendar)
            built[anchor] = made
            return made
        }
        days = [anchors.previous, anchors.current, anchors.next].map(schedule)
        today = schedule(anchors.today)
        yesterday = schedule(anchors.yesterday)
    }
}
