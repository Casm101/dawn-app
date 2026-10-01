import Foundation

/// The waking a day's energy schedule starts from, and the habitual times it is built on.
public struct EnergyAnchor: Hashable, Sendable {
    public let wake: Date
    public let habitual: HabitualSleep

    public init(wake: Date, habitual: HabitualSleep) {
        self.wake = wake
        self.habitual = habitual
    }
}
