import Foundation

/// Every correction and added nap, kept beside what Health imports and never written to it.
public struct SleepEdits: Hashable, Sendable, Codable {
    public private(set) var corrections: [NightCorrection] = []
    public private(set) var naps: [ManualNap] = []

    public init(corrections: [NightCorrection] = [], naps: [ManualNap] = []) {
        self.corrections = corrections
        self.naps = naps
    }

    public func correction(for evening: Date) -> NightCorrection? {
        corrections.first { $0.evening == evening }
    }

    public mutating func save(_ correction: NightCorrection) {
        corrections.removeAll { $0.evening == correction.evening }
        corrections.append(correction)
    }

    /// Back to what Health has for that evening.
    public mutating func reset(_ evening: Date) {
        corrections.removeAll { $0.evening == evening }
    }

    /// Adds a nap, or says why not. `existing` is the sleep already recorded, corrections and naps
    /// included, which a nap may not overlap.
    @discardableResult
    public mutating func add(_ nap: ManualNap, existing: [SleepSession], now: Date, calendar: Calendar) -> NightEditProblem? {
        guard nap.end.timeIntervalSince(nap.start) >= Tuning.Edits.shortestStretch else { return .tooShort }
        guard Self.isEditable(day: calendar.startOfDay(for: nap.start), now: now, calendar: calendar) else { return .tooOld }
        guard !existing.contains(where: { $0.start < nap.end && nap.start < $0.end }) else { return .overlaps }
        naps.append(nap)
        return nil
    }

    public mutating func removeNap(_ id: UUID) {
        naps.removeAll { $0.id == id }
    }

    /// The sessions with corrections in place of the evenings they correct, and the added naps.
    public func apply(to imported: [SleepSession], calendar: Calendar) -> [SleepSession] {
        var sessions = imported
        for correction in corrections {
            let replaced = sessions.filter { $0.kind == .night && calendar.startOfDay(for: $0.evening) == correction.evening }
            sessions.removeAll { replaced.contains($0) }
            if let corrected = correction.session(from: replaced) { sessions.append(corrected) }
        }
        return (sessions + naps.map(\.session)).sorted { $0.start < $1.start }
    }

    /// True for today and the `Tuning.Edits.days - 1` days before it.
    public static func isEditable(day: Date, now: Date, calendar: Calendar) -> Bool {
        let today = calendar.startOfDay(for: now)
        guard let earliest = calendar.date(byAdding: .day, value: -(Tuning.Edits.days - 1), to: today) else { return false }
        return day >= earliest && day <= today
    }
}
