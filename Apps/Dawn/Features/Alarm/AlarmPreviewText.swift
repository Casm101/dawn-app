import DawnCore
import DawnUI
import Foundation

/// The words for the night before an alarm.
nonisolated enum AlarmPreviewText {
    /// "+1h 20m to sleep debt", "pays down 30m", or, to the minute, that it meets need.
    static func debt(_ preview: AlarmSleepPreview) -> String {
        guard !preview.meetsNeed else { return String(localized: "alarm.preview.meets", defaultValue: "meets your sleep need") }
        let amount = DurationFormat.short(abs(preview.debtChange))
        return preview.addsDebt
            ? String(localized: "alarm.preview.adds", defaultValue: "+\(amount) to sleep debt")
            : String(localized: "alarm.preview.paysDown", defaultValue: "pays down \(amount)")
    }

    static func notANight() -> String {
        String(localized: "alarm.preview.notANight", defaultValue: "This alarm is too far from bedtime to end a night, so it does not change sleep debt.")
    }

    static func learning() -> String {
        String(
            localized: "alarm.preview.learning",
            defaultValue: "Based on your usual bedtime and wake time, which you can change in Profile, until Dawn has \(Tuning.Energy.minimumNights) nights of sleep from the last week."
        )
    }

    static func bedtime(_ date: Date) -> String {
        String(localized: "alarm.preview.bedtime", defaultValue: "Bed \(date.formatted(date: .omitted, time: .shortened))")
    }

    static func wakeZone(_ zone: DateInterval) -> String {
        let start = zone.start.formatted(date: .omitted, time: .shortened), end = zone.end.formatted(date: .omitted, time: .shortened)
        return String(localized: "alarm.preview.zone", defaultValue: "Wake zone \(start) – \(end)")
    }

    static func marker(_ ring: Date) -> String {
        String(localized: "alarm.preview.marker", defaultValue: "Alarm at \(ring.formatted(date: .omitted, time: .shortened))")
    }
}
