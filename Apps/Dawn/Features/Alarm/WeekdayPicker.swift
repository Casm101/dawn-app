import DawnCore
import DawnUI
import SwiftUI

/// Seven day chips, Monday first, each switching that day on or off.
struct WeekdayPicker: View {
    @Binding var days: Set<Weekday>

    var body: some View {
        HStack(spacing: DawnSpacing.xs) {
            ForEach(Weekday.allCases.sorted { RepeatPattern.mondayFirst($0) < RepeatPattern.mondayFirst($1) }, id: \.self) { day in
                DayChip(label: Calendar.current.veryShortWeekdaySymbols[day.rawValue - 1], isOn: days.contains(day)) {
                    if days.contains(day) { days.remove(day) } else { days.insert(day) }
                }
                .accessibilityLabel(Calendar.current.weekdaySymbols[day.rawValue - 1])
            }
        }
        .frame(maxWidth: .infinity)
    }
}
