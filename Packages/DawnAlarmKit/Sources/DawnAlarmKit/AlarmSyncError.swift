/// Why the system's alarms could not be checked against the user's list.
public enum AlarmSyncError: Error, Equatable {
    /// The record of which system alarm belongs to which of the user's alarms could not be read, so
    /// nothing is cancelled: an unknown system alarm might be one the user is counting on.
    case linksUnreadable
}
