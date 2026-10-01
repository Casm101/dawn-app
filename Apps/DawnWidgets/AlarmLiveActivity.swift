import ActivityKit
import AlarmKit
import DawnAlarmKit
import DawnUI
import SwiftUI
import WidgetKit

/// How a Dawn alarm shows on the Lock Screen and in the Dynamic Island while it snoozes.
/// AlarmKit needs this for any alarm with a countdown, or the system may drop the alarm.
struct AlarmLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: AlarmAttributes<DawnAlarmMetadata>.self) { context in
            AlarmActivityView(attributes: context.attributes, state: context.state)
                .padding(DawnSpacing.lg)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.center) {
                    AlarmActivityView(attributes: context.attributes, state: context.state)
                }
            } compactLeading: {
                Image(systemName: "alarm")
            } compactTrailing: {
                AlarmCountdownText(state: context.state)
            } minimal: {
                Image(systemName: "alarm")
            }
        }
    }
}
