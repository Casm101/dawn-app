import DawnAlarmKit
import DawnSync

/// The phone's alarm library is the phone's copy of the shared alarm document.
extension AlarmLibrary: SyncedAlarmStore {}
