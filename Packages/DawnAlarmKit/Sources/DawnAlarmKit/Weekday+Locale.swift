import DawnCore
import Foundation

extension Weekday {
    /// The same day as Foundation's `Locale.Weekday`, which AlarmKit's weekly schedule takes.
    var localeWeekday: Locale.Weekday {
        switch self {
        case .sunday: .sunday
        case .monday: .monday
        case .tuesday: .tuesday
        case .wednesday: .wednesday
        case .thursday: .thursday
        case .friday: .friday
        case .saturday: .saturday
        }
    }
}
