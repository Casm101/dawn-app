import Foundation

/// One heart-rate reading. Never stored; only epoch summaries are.
public struct HeartRateSample: Hashable, Sendable {
    public let date: Date
    public let beatsPerMinute: Double

    public init(date: Date, beatsPerMinute: Double) {
        self.date = date
        self.beatsPerMinute = beatsPerMinute
    }
}
