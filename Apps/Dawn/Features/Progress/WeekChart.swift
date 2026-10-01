import DawnCore
import DawnUI
import SwiftUI

/// Seven nights side by side on one axis that runs from evening across midnight to morning.
struct WeekChart: View {
    let slots: [NightSlot]

    var body: some View {
        let axis = NightAxis(slots: slots, calendar: .current)
        HStack(alignment: .top, spacing: DawnSpacing.xs) {
            HourAxisLabels(axis: axis)
            ForEach(slots) { slot in
                NightColumn(slot: slot, axis: axis)
            }
        }
        .frame(maxHeight: .infinity, alignment: .top)
    }
}
