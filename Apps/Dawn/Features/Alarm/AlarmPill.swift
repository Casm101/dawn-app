import DawnUI
import SwiftUI

/// The toolbar button that shows the next alarm and opens the alarm list.
struct AlarmPill: View {
    @Environment(AlarmStore.self) private var store
    @State private var showing = false

    var body: some View {
        Button { showing = true } label: {
            HStack(spacing: DawnSpacing.xs) {
                Image(systemName: "alarm")
                Text(title).monospacedDigit()
            }
        }
        .sheet(isPresented: $showing) { AlarmListView() }
    }

    private var title: String {
        guard let next = store.nextRing else {
            return String(localized: "alarm.pill.none", defaultValue: "Alarm")
        }
        return next.formatted(date: .omitted, time: .shortened)
    }
}
