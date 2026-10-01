/// The parts of a waking day, in the order they come.
public enum EnergyPhase: String, CaseIterable, Hashable, Sendable {
    case grogginess
    case morningPeak
    case afternoonDip
    case eveningPeak
    case windDown
    case melatoninWindow
}
