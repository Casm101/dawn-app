/// What a sleep sample says the sleeper was doing. Mirrors Health's sleep values, minus "in bed".
public enum SleepStage: String, Codable, Sendable, CaseIterable {
    case awake
    case rem
    case core
    case deep
    /// Asleep, with no stage recorded.
    case unspecified

    public var isAsleep: Bool { self != .awake }

    /// True for the stages a Watch records: REM, core and deep.
    public var isStaged: Bool {
        switch self {
        case .rem, .core, .deep: true
        case .awake, .unspecified: false
        }
    }
}
