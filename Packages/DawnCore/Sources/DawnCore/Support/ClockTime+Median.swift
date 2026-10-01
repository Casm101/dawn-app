import Foundation

extension ClockTime {
    /// The time `minutes` after midnight, wrapping round the day.
    public init(minutes: Int) {
        let wrapped = ((minutes % 1440) + 1440) % 1440
        self.init(hour: wrapped / 60, minute: wrapped % 60)!
    }

    /// The weighted median of times of day, measured round the clock so 23:30 and 00:30 sit an hour
    /// apart: each time becomes its offset from the times' circular mean, and the median offset is
    /// added back.
    public static func median(_ times: [ClockTime], weights: [Double]) -> ClockTime {
        let angles = times.map { Double($0.minutesSinceMidnight) / 1440 * 2 * .pi }
        let x = zip(angles, weights).reduce(0) { $0 + cos($1.0) * $1.1 }
        let y = zip(angles, weights).reduce(0) { $0 + sin($1.0) * $1.1 }
        let mean = Int((atan2(y, x) / (2 * .pi) * 1440).rounded())
        let offsets = times.map { (($0.minutesSinceMidnight - mean) % 1440 + 2160) % 1440 - 720 }
        let sorted = zip(offsets, weights).sorted { $0.0 < $1.0 }
        let half = weights.reduce(0, +) / 2
        var total = 0.0
        for (offset, weight) in sorted {
            total += weight
            if total >= half { return ClockTime(minutes: mean + offset) }
        }
        return ClockTime(minutes: mean)
    }
}
