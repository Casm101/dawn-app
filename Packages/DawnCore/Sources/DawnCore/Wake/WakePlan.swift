import Foundation

/// The wake window to arm next: the earliest ring of any enabled alarm within the arming horizon,
/// from the alarm's window length before it up to the ring (WakeTF's next-occurrence rule, MIT,
/// across repeat days).
public struct WakePlan: Hashable, Sendable, Codable {
    public let alarmID: UUID
    public let windowStart: Date
    /// The ring, where the phone's alarm stands.
    public let windowEnd: Date

    public init(alarmID: UUID, windowStart: Date, windowEnd: Date) {
        self.alarmID = alarmID
        self.windowStart = windowStart
        self.windowEnd = windowEnd
    }

    /// Nil when nothing rings within the arming horizon. A ring at or before `completed`, the one
    /// whose window has just run, is skipped, so opening the app from the wake alert arms the next night.
    public init?(alarms: [AlarmDefinition], now: Date, completed: Date? = nil, calendar: Calendar) {
        guard let next = Self.upcoming(alarms: alarms, now: now, completed: completed, within: Tuning.Wake.armingHorizon, calendar: calendar).first,
              next.windowEnd.timeIntervalSince(now) >= Tuning.Wake.shortestWindow else { return nil }
        self = next
    }

    /// Every ring to come within `horizon`, earliest first, one window each. A one-off alarm counts
    /// only for the ring it was set for, so once that has passed it plans nothing more.
    public static func upcoming(alarms: [AlarmDefinition], now: Date, completed: Date? = nil, within horizon: TimeInterval, calendar: Calendar) -> [WakePlan] {
        var after = max(now, completed ?? now), plans: [WakePlan] = []
        while plans.count < Tuning.Wake.upcomingLimit {
            let rings = alarms.compactMap { alarm -> (AlarmDefinition, Date)? in
                guard alarm.settings.isEnabled, let ring = AlarmOccurrence.next(alarm.settings, after: after, calendar: calendar) else { return nil }
                if let once = alarm.onceRing(calendar: calendar), once != ring { return nil }
                return (alarm, ring)
            }
            guard let (alarm, ring) = rings.min(by: { $0.1 < $1.1 }), ring.timeIntervalSince(now) <= horizon else { break }
            let length = TimeInterval(alarm.settings.windowMinutes * 60)
            plans.append(WakePlan(alarmID: alarm.id, windowStart: ring.addingTimeInterval(-length), windowEnd: ring))
            after = ring
        }
        return plans
    }

    public var length: TimeInterval { windowEnd.timeIntervalSince(windowStart) }

    /// True while the alarm still exists, is on, rings at this window's end and keeps its window
    /// length, so a window armed before an edit is not run after it.
    public func isCurrent(in alarms: [AlarmDefinition], calendar: Calendar) -> Bool {
        guard let settings = alarms.first(where: { $0.id == alarmID })?.settings, settings.isEnabled else { return false }
        return AlarmOccurrence.rings(settings, at: windowEnd, calendar: calendar)
            && TimeInterval(settings.windowMinutes * 60) == length
    }

    /// When the session should start: the window's start, or now if the window has already begun.
    public func start(at now: Date) -> Date { max(windowStart, now) }
}
