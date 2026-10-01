import DawnCore
import DawnUI
import SwiftUI

/// Every recorded night of the two weeks, newest first. Nights missing from Health are left out.
struct NightList: View {
    let slots: [NightSlot]

    var body: some View {
        VStack(alignment: .leading, spacing: DawnSpacing.sm) {
            Text(String(localized: "progress.list.title", defaultValue: "All sleep times"))
                .font(DawnFont.title)
            let recorded = slots.reversed().filter { !$0.nights.isEmpty }
            if recorded.isEmpty {
                Text(String(localized: "progress.list.empty", defaultValue: "No nights in Apple Health from the last two weeks."))
                    .font(DawnFont.body)
                    .foregroundStyle(DawnColor.secondaryText)
            }
            ForEach(recorded) { slot in
                NavigationLink(value: slot) {
                    NightRow(slot: slot)
                }
                .buttonStyle(.plain)
            }
        }
    }
}
