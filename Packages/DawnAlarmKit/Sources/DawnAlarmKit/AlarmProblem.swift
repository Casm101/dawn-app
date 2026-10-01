import DawnCore
import Foundation

/// Something about the alarms the user should be told.
public enum AlarmProblem: Hashable, Sendable {
    /// The system refused this alarm, so it was switched off.
    case couldNotSchedule(ClockTime)
    /// A one-off alarm too close to its time to rely on; it was not switched on.
    case tooSoonToSet(ClockTime)
    /// Saved, but the ring at `skipped` may not happen; it rings as set from `following`.
    case mayMissNextRing(skipped: Date, following: Date)
    /// The saved alarms could not be read; the system's alarms are left as they were and the list
    /// cannot be changed until they can be read.
    case couldNotLoad
    /// The system's alarms could not be checked against the list this time; nothing was cancelled.
    case couldNotCheck
    /// The alarms could not be written to the phone.
    case couldNotSave
}
