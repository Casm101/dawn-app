import DawnCore
import Foundation

/// Keeps the system's alarms in step with the user's list. The system never changes an alarm in
/// place: every change cancels the old system alarm and schedules a new one under a new id.
public actor AlarmSystemSync {
    private let scheduler: any AlarmScheduling
    private let linksFile: JSONFile<[UUID: UUID]>?
    /// Which system alarm currently stands for each of the user's alarms. Phone-local.
    public private(set) var links: [UUID: UUID]

    public init(scheduler: any AlarmScheduling, linksFile: JSONFile<[UUID: UUID]>? = nil) {
        self.scheduler = scheduler
        self.linksFile = linksFile
        links = (try? linksFile?.read()) ?? [:]
    }

    /// Cancels the alarm's current system alarm, then schedules a fresh one if it is enabled.
    public func apply(_ alarm: AlarmDefinition) async throws {
        try await cancelLink(for: alarm.id)
        guard alarm.isEnabled else { return }
        let systemID = UUID()
        try await scheduler.schedule(id: systemID, alarm: alarm)
        links[alarm.id] = systemID
        save()
    }

    public func remove(_ alarmID: UUID) async throws {
        try await cancelLink(for: alarmID)
    }

    /// Cancels system alarms Dawn no longer knows, and returns the enabled alarms whose system
    /// alarm has gone, for example a one-off alarm that already rang.
    public func reconcile(_ document: AlarmDocument) async throws -> Set<UUID> {
        let system = try await scheduler.systemIDs()
        let known = Set(document.alarms.map(\.id))
        links = links.filter { known.contains($0.key) }
        for orphan in system.subtracting(links.values) {
            try? await scheduler.cancel(id: orphan)
        }
        let lost = document.alarms.filter { alarm in
            guard alarm.isEnabled else { return false }
            guard let link = links[alarm.id] else { return true }
            return !system.contains(link)
        }.map(\.id)
        for id in lost { links[id] = nil }
        save()
        return Set(lost)
    }

    private func cancelLink(for alarmID: UUID) async throws {
        guard let systemID = links[alarmID] else { return }
        try? await scheduler.cancel(id: systemID)
        links[alarmID] = nil
        save()
    }

    private func save() {
        try? linksFile?.write(links)
    }
}
