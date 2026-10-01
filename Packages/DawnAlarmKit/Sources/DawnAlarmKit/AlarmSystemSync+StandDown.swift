import DawnCore
import Foundation

extension AlarmSystemSync {
    /// Stands down one ring of an alarm. A repeating alarm is scheduled again without that weekday,
    /// with a one-off on the same weekday a week later; a one-off alarm is cancelled. The full alarm
    /// comes back at the first reconcile after the ring.
    public func standDown(_ alarm: AlarmDefinition, ring: Date) async throws {
        try await serially { try await self.standDownNow(alarm, ring: ring) }
    }

    private func standDownNow(_ alarm: AlarmDefinition, ring: Date) async throws {
        guard clock() < ring, skips[alarm.id]?.ring != ring,
              let weekday = Weekday(rawValue: calendar.component(.weekday, from: ring)) else { return }
        await dropSkip(for: alarm.id)
        var fixedID: UUID?
        if alarm.settings.repeats, let nextWeek = calendar.date(byAdding: .day, value: 7, to: ring) {
            let id = UUID()
            try await scheduler.schedule(id: id, at: nextWeek, alarm: alarm.settings)
            fixedID = id
        }
        skips[alarm.id] = BackstopSkip(ring: ring, weekday: weekday, fixedID: fixedID)
        try? saveSkips()
        try await applyNow(alarm)
    }

    /// Schedules the alarm, leaving out a stood-down ring that has not passed. False when that
    /// leaves nothing to schedule.
    func scheduleHonouringSkip(_ alarm: AlarmDefinition, id: UUID) async throws -> Bool {
        var settings = alarm.settings
        if let skip = skips[alarm.id], skip.ring > clock() {
            guard settings.repeats else { return false }
            settings.repeatDays.remove(skip.weekday)
            guard !settings.repeatDays.isEmpty else { return false }
        }
        try await scheduler.schedule(id: id, alarm: settings)
        return true
    }

    /// Brings back the full alarm for every stood-down ring that has passed. A one-off alarm stays
    /// unscheduled, so it is switched off as rung.
    func restorePassedSkips(_ document: AlarmDocument) async throws {
        let passed = skips.filter { $0.value.ring <= clock() }
        for (id, _) in passed {
            await dropSkip(for: id)
            if let alarm = document.alarm(id), alarm.settings.repeats { try await applyNow(alarm) }
        }
    }

    /// Forgets the stood-down ring and cancels the one-off standing in for next week.
    func dropSkip(for alarmID: UUID) async {
        guard let skip = skips.removeValue(forKey: alarmID) else { return }
        if let fixedID = skip.fixedID { try? await scheduler.cancel(id: fixedID) }
        try? saveSkips()
    }

    private func saveSkips() throws {
        try skipsFile?.write(skips)
    }
}
