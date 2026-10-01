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
            ForEach(slots.reversed().filter { !$0.nights.isEmpty }) { slot in
                NavigationLink(value: slot) {
                    NightRow(slot: slot)
                }
                .buttonStyle(.plain)
            }
        }
    }
}
