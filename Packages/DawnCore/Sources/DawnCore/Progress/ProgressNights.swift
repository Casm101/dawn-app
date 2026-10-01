import Foundation

/// The nights the Progress tab shows: `Tuning.Progress.nights` evenings ending with tonight, oldest first.
public enum ProgressNights {
    public static func slots(from sessions: [SleepSession], now: Date, calendar: Calendar) -> [NightSlot] {
        let tonight = calendar.startOfDay(for: now)
        let byEvening = Dictionary(grouping: sessions.filter { $0.kind == .night }) {
            calendar.startOfDay(for: $0.evening)
        }
        return (0..<Tuning.Progress.nights).reversed().compactMap { back in
            guard let evening = calendar.date(byAdding: .day, value: -back, to: tonight) else { return nil }
            let nights = (byEvening[evening] ?? []).sorted { $0.start < $1.start }
            return NightSlot(evening: evening, nights: nights, isTonight: back == 0)
        }
    }

    /// The slots in pages of `Tuning.Progress.nightsPerPage`, oldest page first.
    public static func pages(_ slots: [NightSlot]) -> [[NightSlot]] {
        stride(from: 0, to: slots.count, by: Tuning.Progress.nightsPerPage).map {
            Array(slots[$0..<min($0 + Tuning.Progress.nightsPerPage, slots.count)])
        }
    }
}
