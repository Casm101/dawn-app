/// One habit on one waking date.
public struct HabitDay: Hashable, Sendable, Codable {
    public let habit: Habit
    public let day: CalendarDay

    public init(habit: Habit, day: CalendarDay) {
        self.habit = habit
        self.day = day
    }
}
