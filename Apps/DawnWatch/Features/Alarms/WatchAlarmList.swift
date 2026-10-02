import DawnCore
import DawnSync
import DawnUI
import SwiftUI

/// The alarms set on either device, each with its switch; tap one to change it.
struct WatchAlarmList: View {
    @Environment(WatchAlarmStore.self) private var alarms
    @Environment(AlarmSyncEngine.self) private var sync

    var body: some View {
        NavigationStack {
            List {
                if sync.isWaiting {
                    Label(String(localized: "watch.sync.waiting", defaultValue: "Waiting for iPhone"), systemImage: "iphone.radiowaves.left.and.right")
                        .font(DawnFont.caption)
                        .foregroundStyle(DawnColor.secondaryText)
                }
                if alarms.alarms.isEmpty {
                    TonightView()
                } else {
                    WakeStatusRow()
                }
                ForEach(alarms.alarms) { alarm in
                    WatchAlarmRow(alarm: alarm)
                }
                .onDelete { offsets in
                    for id in offsets.map({ alarms.alarms[$0].id }) { alarms.delete(id) }
                }
            }
            .navigationTitle(String(localized: "watch.title", defaultValue: "Dawn"))
            .navigationDestination(for: AlarmDefinition.self) { WatchAlarmEditor(id: $0.id, settings: $0.settings) }
        }
    }
}
