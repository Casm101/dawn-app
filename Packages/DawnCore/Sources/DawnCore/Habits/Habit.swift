/// A habit timed from the day's energy schedule, shown as a chip on the timeline.
public enum Habit: String, CaseIterable, Hashable, Sendable, Codable {
    case morningLight
    case caffeineCutoff
    case dimLights
    case windDown
    case melatonin
    case rateLastNight

    /// Shown until the user turns them off. The melatonin supplement waits to be turned on.
    public static let shownByDefault: Set<Habit> = Set(allCases).subtracting([.melatonin])
}
