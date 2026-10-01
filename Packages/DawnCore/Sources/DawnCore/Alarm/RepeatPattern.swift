/// How a set of repeat days reads to a person: the named patterns first, otherwise the days in order.
public enum RepeatPattern: Hashable, Sendable {
    case once
    case everyDay
    case weekdays
    case weekend
    /// Days in week order, Monday first.
    case days([Weekday])

    public init(_ days: Set<Weekday>) {
        switch days {
        case []: self = .once
        case Set(Weekday.allCases): self = .everyDay
        case Weekday.weekdays: self = .weekdays
        case Weekday.weekend: self = .weekend
        default: self = .days(days.sorted { Self.mondayFirst($0) < Self.mondayFirst($1) })
        }
    }

    /// Monday is 0 and Sunday 6.
    public static func mondayFirst(_ day: Weekday) -> Int { (day.rawValue + 5) % 7 }
}
