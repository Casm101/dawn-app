import Foundation

/// Durations as people read them on a sleep screen: "6h 22m", "16m".
public nonisolated enum DurationFormat {
    public static func short(_ interval: TimeInterval, locale: Locale = .current) -> String {
        let minutes = (interval / 60).rounded()
        return Duration.seconds(minutes * 60).formatted(
            .units(allowed: [.hours, .minutes], width: .narrow, zeroValueUnits: .hide)
                .locale(locale)
        )
    }
}
