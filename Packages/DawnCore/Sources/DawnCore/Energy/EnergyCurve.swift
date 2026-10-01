import Foundation

/// Predicted alertness through one waking day, every `Tuning.Energy.gridStep`.
public struct EnergyCurve: Hashable, Sendable {
    public struct Point: Hashable, Sendable {
        public let date: Date
        public let alertness: Double

        public init(date: Date, alertness: Double) {
            self.date = date
            self.alertness = alertness
        }
    }

    public let points: [Point]

    public init(points: [Point]) { self.points = points }

    /// The model run from `wake` to `end`: S from `pressureAtWake`, the rhythms peaking at
    /// `peakHour` of the local day, and sleep inertia.
    public init(wake: Date, end: Date, pressureAtWake: Double, peakHour: Double, calendar: Calendar) {
        var points: [Point] = []
        var date = wake
        while date <= end {
            let hours = date.timeIntervalSince(wake) / 3600
            let parts = calendar.dateComponents([.hour, .minute], from: date)
            let hourOfDay = Double(parts.hour ?? 0) + Double(parts.minute ?? 0) / 60
            let alertness = AlertnessModel.pressure(afterWaking: hours, from: pressureAtWake)
                + AlertnessModel.rhythm(atHour: hourOfDay, peakHour: peakHour)
                + AlertnessModel.inertia(afterWaking: hours)
            points.append(Point(date: date, alertness: alertness))
            date = date.addingTimeInterval(Tuning.Energy.gridStep)
        }
        self.points = points
    }

    /// Alertness on the drawn scale: 0 at extreme sleepiness, 1 at the top.
    public static func level(_ alertness: Double) -> Double {
        let scale = Tuning.Energy.scale
        return min(1, max(0, (alertness - scale.lowerBound) / (scale.upperBound - scale.lowerBound)))
    }
}
