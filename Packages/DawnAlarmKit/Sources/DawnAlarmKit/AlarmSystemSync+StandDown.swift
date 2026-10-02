import DawnCore
import Foundation

extension AlarmSystemSync {
    /// Brings back every alarm whose stood-down ring has passed. Run whenever the phone app runs,
    /// including when the Watch's message wakes it in the background.
    public func restoreStoodDown(_ document: AlarmDocument) async {
        try? await serially { try await self.restorePassedSkips(document) }
    }

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
            let id = BackstopSkip.standInID(for: alarm.id, at: nextWeek)
            try await scheduler.schedule(id: id, at: nextWeek, alarm: alarm.settings)
            fixedID = id
        }
        skips[alarm.id] = BackstopSkip(ring: ring, weekday: weekday, fixedID: fixedID)
        do {
            try saveSkips()
        } catch {
            // A stand-in nothing records could never be cancelled; without it the backstop rings.
            skips[alarm.id] = nil
            if let fixedID { try? await scheduler.cancel(id: fixedID) }
            throw error
        }
        try await applyNow(alarm)
    }

    /// Schedules the alarm, leaving out a stood-down ring that is still to come and still one of
    /// the alarm's rings. A skip the alarm has been moved away from is dropped with its stand-in.
    /// False when what is left has nothing to schedule.
    func scheduleHonouringSkip(_ alarm: AlarmDefinition, id: UUID) async throws -> Bool {
        var settings = alarm.settings
        if let skip = skips[alarm.id] {
            if skip.ring > clock(), AlarmOccurrence.rings(settings, at: skip.ring, calendar: calendar) {
                guard settings.repeats else { return false }
                settings.repeatDays.remove(skip.weekday)
                guard !settings.repeatDays.isEmpty else { return false }
            } else {
                await dropSkip(for: alarm.id)
            }
        }
        try await scheduler.schedule(id: id, alarm: settings)
        return true
    }

    /// Brings back the full alarm for every stood-down ring that has passed, and cancels any stand-in
    /// no skip owns, for an alarm that exists or was deleted, so one whose record was lost cannot
    /// ring. Other exact-moment alarms are left alone. A one-off alarm stays unscheduled, so it is
    /// switched off as rung.
    func restorePassedSkips(_ document: AlarmDocument) async throws {
        if skipsLost {
            for alarm in document.alarms where alarm.settings.isEnabled && alarm.settings.repeats { try await applyNow(alarm) }
            skipsLost = false
            try? saveSkips()
        }
        let passed = skips.filter { $0.value.ring <= clock() }
        for (id, _) in passed {
            await dropSkip(for: id)
            if let alarm = document.alarm(id), alarm.settings.repeats { try await applyNow(alarm) }
        }
        let owned = Set(skips.values.compactMap(\.fixedID))
        let known = document.alarms.map(\.id) + document.tombstones.map(\.id)
        for fixed in await scheduler.scheduled() where !owned.contains(fixed.id)
            && known.contains(where: { BackstopSkip.standInID(for: $0, at: fixed.fireDate) == fixed.id }) {
            try? await scheduler.cancel(id: fixed.id)
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
