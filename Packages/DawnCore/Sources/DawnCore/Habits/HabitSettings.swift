/// Which habits show on the timeline and which of those send a reminder.
public struct HabitSettings: Hashable, Sendable, Codable {
    public private(set) var shown: Set<Habit>
    public private(set) var reminded: Set<Habit>

    public init(shown: Set<Habit> = Habit.shownByDefault, reminded: Set<Habit> = []) {
        self.shown = shown
        self.reminded = reminded.intersection(shown)
    }

    public func isShown(_ habit: Habit) -> Bool { shown.contains(habit) }

    public func reminds(_ habit: Habit) -> Bool { reminded.contains(habit) }

    /// Turning a habit off turns its reminder off too.
    public mutating func show(_ habit: Habit, _ on: Bool) {
        if on {
            shown.insert(habit)
        } else {
            shown.remove(habit)
            reminded.remove(habit)
        }
    }

    /// A reminder is only kept for a habit that is shown.
    public mutating func remind(_ habit: Habit, _ on: Bool) {
        if on, shown.contains(habit) { reminded.insert(habit) } else { reminded.remove(habit) }
    }
}
