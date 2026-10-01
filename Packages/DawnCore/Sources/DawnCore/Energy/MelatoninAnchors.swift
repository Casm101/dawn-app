import Foundation

/// The evening anchors, all from habitual bedtime: melatonin onset two hours before it, the
/// melatonin window an hour after onset, and wind-down no earlier than onset.
public struct MelatoninAnchors: Hashable, Sendable {
    public let onset: Date
    public let windDownStart: Date
    public let windowStart: Date
    public let windowEnd: Date

    public init(bedtime: Date) {
        let onset = bedtime.addingTimeInterval(-Tuning.Energy.melatoninOnsetBeforeBed)
        self.onset = onset
        windDownStart = max(onset, bedtime.addingTimeInterval(-Tuning.Energy.windDownBeforeBed))
        windowStart = onset.addingTimeInterval(Tuning.Energy.melatoninWindowAfterOnset)
        windowEnd = windowStart.addingTimeInterval(Tuning.Energy.melatoninWindow)
    }
}
