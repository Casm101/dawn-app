import Foundation

/// Every correction and added nap, kept beside what Health imports and never written to it.
public struct SleepEdits: Hashable, Sendable, Codable {
    public private(set) var corrections: [NightCorrection] = []
    public private(set) var naps: [ManualNap] = []

    public init(corrections: [NightCorrection] = [], naps: [ManualNap] = []) {
        self.corrections = corrections
        self.naps = naps
    }

    public func correction(for day: CalendarDay) -> NightCorrection? {
        corrections.first { $0.day == day }
    }

    /// Saves a correction, or says why not: the corrected sleep has to stay on the evening it corrects.
    @discardableResult
    public mutating func save(_ correction: NightCorrection, calendar: Calendar) -> NightEditProblem? {
        if let first = correction.segments.first,
           CalendarDay(first.start.addingTimeInterval(-Tuning.Sleep.nightNameShift), calendar: calendar) != correction.day {
            return .movesNight
        }
        corrections.removeAll { $0.day == correction.day }
        corrections.append(correction)
        return nil
    }

    /// Back to what Health has for that evening.
    public mutating func reset(_ day: CalendarDay) {
        corrections.removeAll { $0.day == day }
    }

    /// Adds a nap, or says why not. A nap may not overlap `existing`, the sleep already recorded,
    /// nor another added nap, even one left out while a night covers it.
    @discardableResult
    public mutating func add(_ nap: ManualNap, existing: [SleepSession], now: Date, calendar: Calendar) -> NightEditProblem? {
        guard nap.end > nap.start else { return .endsBeforeStart }
        guard nap.end.timeIntervalSince(nap.start) >= Tuning.Edits.shortestStretch else { return .tooShort }
        guard nap.end <= now else { return .inFuture }
        guard Self.isEditable(day: calendar.startOfDay(for: nap.start), now: now, calendar: calendar) else { return .tooOld }
        let taken = existing + naps.map(\.session)
        guard !taken.contains(where: { $0.start < nap.end && nap.start < $0.end }) else { return .overlaps }
        naps.append(nap)
        return nil
    }

    public mutating func removeNap(_ id: UUID) {
        naps.removeAll { $0.id == id }
    }

    /// The sessions with corrections in place of the evenings they correct, and the added naps.
    /// An added nap that a later correction or import overlaps is left out while it does.
    public func apply(to imported: [SleepSession], calendar: Calendar) -> [SleepSession] {
        var sessions = imported
        for correction in corrections {
            let replaced = sessions.filter { $0.kind == .night && CalendarDay($0.evening, calendar: calendar) == correction.day }
            sessions.removeAll { replaced.contains($0) }
            if let corrected = correction.session(from: replaced) { sessions.append(corrected) }
        }
        let added = naps.map(\.session).filter { nap in !sessions.contains { $0.start < nap.end && nap.start < $0.end } }
        return (sessions + added).sorted { $0.start < $1.start }
    }

    /// The edits for days Health is still read for, `Tuning.Sleep.importDays`. Older ones go: no
    /// night or nap they lie over is imported any more, and nothing that reads sleep looks that far back.
    public func pruned(now: Date, calendar: Calendar) -> SleepEdits {
        guard let earliest = calendar.date(byAdding: .day, value: -Tuning.Sleep.importDays, to: calendar.startOfDay(for: now)) else { return self }
        return SleepEdits(
            corrections: corrections.filter { ($0.day.start(in: calendar) ?? .distantPast) >= earliest },
            naps: naps.filter { calendar.startOfDay(for: $0.start) >= earliest }
        )
    }

    /// True for an evening Progress shows: tonight's and the `Tuning.Edits.days - 1` before it.
    public static func isEditable(evening: Date, now: Date, calendar: Calendar) -> Bool {
        let tonight = ProgressNights.tonight(now: now, calendar: calendar)
        guard let earliest = calendar.date(byAdding: .day, value: -(Tuning.Edits.days - 1), to: tonight) else { return false }
        let day = calendar.startOfDay(for: evening)
        return day >= earliest && day <= tonight
    }

    /// True for today and the `Tuning.Edits.days - 1` days before it.
    public static func isEditable(day: Date, now: Date, calendar: Calendar) -> Bool {
        let today = calendar.startOfDay(for: now)
        guard let earliest = calendar.date(byAdding: .day, value: -(Tuning.Edits.days - 1), to: today) else { return false }
        return day >= earliest && day <= today
    }
}
