#if canImport(AlarmKit)
import AlarmKit

/// What Dawn attaches to its AlarmKit alarms. Shared with the widget extension's Live Activity.
public struct DawnAlarmMetadata: AlarmMetadata {
    public init() {}
}
#endif
