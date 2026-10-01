import DawnSync
import DawnUI
import SwiftUI

/// Says so while the Watch has not yet received the latest change.
struct SyncStatusRow: View {
    @Environment(AlarmSyncEngine.self) private var sync

    var body: some View {
        if sync.isWaiting {
            Label(String(localized: "alarms.sync.waiting", defaultValue: "Waiting for Watch"), systemImage: "applewatch.radiowaves.left.and.right")
                .font(DawnFont.caption)
                .foregroundStyle(DawnColor.secondaryText)
        }
    }
}
