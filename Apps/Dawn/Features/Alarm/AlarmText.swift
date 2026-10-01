import DawnCore
import Foundation

/// How alarm times and repeat days read in the interface.
enum AlarmText {
    static func time(_ time: ClockTime) -> String {
        time.date(on: Date(), calendar: .current).formatted(date: .omitted, time: .shortened)
    }

    static func days(_ days: Set<Weekday>) -> String {
        switch RepeatPattern(days) {
        case .once: String(localized: "alarm.repeat.once", defaultValue: "Once")
        case .everyDay: String(localized: "alarm.repeat.everyDay", defaultValue: "Every day")
        case .weekdays: String(localized: "alarm.repeat.weekdays", defaultValue: "Weekdays")
        case .weekend: String(localized: "alarm.repeat.weekend", defaultValue: "Weekends")
        case .days(let list):
            list.map { Calendar.current.shortWeekdaySymbols[$0.rawValue - 1] }
                .formatted(.list(type: .and, width: .narrow))
        }
    }

    static func sound(_ sound: AlarmSound) -> String {
        switch sound {
        case .chimes: String(localized: "alarm.sound.chimes", defaultValue: "Chimes")
        case .sunrise: String(localized: "alarm.sound.sunrise", defaultValue: "Sunrise")
        case .pulse: String(localized: "alarm.sound.pulse", defaultValue: "Pulse")
        }
    }
}
