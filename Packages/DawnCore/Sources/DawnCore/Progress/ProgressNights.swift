import Foundation

/// The nights the Progress tab shows: `Tuning.Progress.nights` evenings ending with tonight, oldest first.
public enum ProgressNights {
    /// Tonight's evening: today's, or before daytime starts (`Tuning.Sleep.daytimeStartHour`, on the
    /// wall clock) the one that began yesterday, since the night still to come belongs to it, unless
    /// that night's main sleep has already ended, as when an early alarm woke the user.
    public static func tonight(now: Date, sessions: [SleepSession] = [], calendar: Calendar) -> Date {
        let today = calendar.startOfDay(for: now)
        guard calendar.component(.hour, from: now) < Tuning.Sleep.daytimeStartHour,
              let yesterday = calendar.date(byAdding: .day, value: -1, to: today) else { return today }
        let slept = sessions.contains { night in
            night.kind == .night && night.end <= now && night.span >= Tuning.Energy.mainSleep
                && calendar.startOfDay(for: night.evening) == yesterday
        }
        return slept ? today : yesterday
    }

    public static func slots(from sessions: [SleepSession], now: Date, calendar: Calendar) -> [NightSlot] {
        let tonight = tonight(now: now, sessions: sessions, calendar: calendar)
        let byEvening = Dictionary(grouping: sessions.filter { $0.kind == .night }) {
            calendar.startOfDay(for: $0.evening)
        }
        return (0..<Tuning.Progress.nights).reversed().compactMap { back in
            guard let evening = calendar.date(byAdding: .day, value: -back, to: tonight) else { return nil }
            let nights = (byEvening[evening] ?? []).sorted { $0.start < $1.start }
            let label = NightLabel(evening: evening, tonight: tonight, calendar: calendar)
            return NightSlot(evening: evening, nights: nights, isTonight: back == 0, label: label)
        }
    }

    /// The slots in pages of `Tuning.Progress.nightsPerPage`, oldest page first.
    public static func pages(_ slots: [NightSlot]) -> [[NightSlot]] {
        stride(from: 0, to: slots.count, by: Tuning.Progress.nightsPerPage).map {
            Array(slots[$0..<min($0 + Tuning.Progress.nightsPerPage, slots.count)])
        }
    }
}
