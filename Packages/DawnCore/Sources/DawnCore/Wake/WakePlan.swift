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

    /// Nil when nothing rings within the horizon. A ring at or before `completed`, the one whose
    /// window has just run, is skipped, so opening the app from the wake alert arms the next night.
    public init?(alarms: [AlarmDefinition], now: Date, completed: Date? = nil, calendar: Calendar) {
        let after = max(now, completed ?? now)
        let rings = alarms.map(\.settings).enumerated().compactMap { index, settings -> (Int, Date)? in
            guard settings.isEnabled, let ring = AlarmOccurrence.next(settings, after: after, calendar: calendar) else { return nil }
            return (index, ring)
        }
        guard let (index, ring) = rings.min(by: { $0.1 < $1.1 }),
              ring.timeIntervalSince(now) <= Tuning.Wake.armingHorizon,
              ring.timeIntervalSince(now) >= Tuning.Wake.shortestWindow else { return nil }
        let length = TimeInterval(alarms[index].settings.windowMinutes * 60)
        self.init(alarmID: alarms[index].id, windowStart: ring.addingTimeInterval(-length), windowEnd: ring)
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
