import Foundation

/// The bedtime and wake time the user gives Dawn, used until it has enough nights of its own.
public struct UsualSleep: Hashable, Codable, Sendable {
    public var bedtime: ClockTime
    public var wakeTime: ClockTime

    public init(bedtime: ClockTime = Tuning.Energy.usualBedtime, wakeTime: ClockTime = Tuning.Energy.usualWakeTime) {
        self.bedtime = bedtime
        self.wakeTime = wakeTime
    }
}
