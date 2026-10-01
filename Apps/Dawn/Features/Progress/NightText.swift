import DawnCore
import Foundation

/// How nights and their times read on the Progress tab.
enum NightText {
    static func label(for slot: NightSlot, now: Date = Date()) -> String {
        switch NightLabel(evening: slot.evening, now: now, calendar: .current) {
        case .tonight: String(localized: "night.tonight", defaultValue: "Tonight")
        case .lastNight: String(localized: "night.last", defaultValue: "Last night")
        case .evening(let day):
            String(localized: "night.named", defaultValue: "\(day.formatted(.dateTime.weekday(.wide))) night")
        case .earlier(let day):
            String(
                localized: "night.dated",
                defaultValue: "\(day.formatted(.dateTime.weekday(.wide))) night, \(day.formatted(.dateTime.day().month(.abbreviated)))"
            )
        }
    }

    /// "00:45 – 07:07" from the first sleep to the final wake.
    static func bedToWake(_ slot: NightSlot) -> String {
        guard let bed = slot.nights.first?.start, let wake = slot.nights.last?.end else { return "" }
        return range(bed, wake)
    }

    static func range(_ start: Date, _ end: Date) -> String {
        let from = start.formatted(date: .omitted, time: .shortened)
        let to = end.formatted(date: .omitted, time: .shortened)
        return String(localized: "night.range", defaultValue: "\(from) – \(to)")
    }

    /// The span of evenings on one chart page, such as "Sep 17 – 23".
    static func weekRange(_ slots: [NightSlot]) -> String {
        guard let first = slots.first?.evening, let last = slots.last?.evening else { return "" }
        return (first..<last).formatted(.interval.month(.abbreviated).day())
    }

    /// The hour of day an axis value stands for, as the locale writes hours: "21" or "9p".
    static func clock(axisValue: Double) -> String {
        let hour = NightAxis.hourOfDay(axisValue)
        let reference = Calendar.current.date(bySettingHour: hour, minute: 0, second: 0, of: Date()) ?? Date()
        return reference.formatted(.dateTime.hour(.defaultDigits(amPM: .narrow)))
    }
}
