import DawnCore
import Foundation

extension AlarmLibrary {
    /// Takes a wake window's outcome from the Watch. An early wake that arrives before the ring
    /// stands that ring's system alarm down; anything later leaves the alarm as it is, because it
    /// has already rung. Returns true when the ring was stood down.
    @discardableResult
    public func received(_ outcome: WakeOutcome, at now: Date = Date()) async -> Bool {
        guard !isReadOnly, outcome.standsDownBackstop(at: now),
              let alarm = document.alarm(outcome.alarmID), alarm.settings.isEnabled,
              AlarmOccurrence.rings(alarm.settings, at: outcome.windowEnd, calendar: calendar) else { return false }
        do {
            try await sync.standDown(alarm, ring: outcome.windowEnd)
            return true
        } catch {
            return false
        }
    }
}
