import DawnCore
import Foundation

/// Keeps the system's alarms in step with the user's list. The system never changes an alarm in
/// place: every change cancels the old system alarm and schedules a new one under a new id.
/// Operations run one at a time, so a quick on-then-off can never leave a system alarm behind.
public actor AlarmSystemSync {
    private let scheduler: any AlarmScheduling
    private let linksFile: JSONFile<[UUID: UUID]>?
    /// Which system alarm currently stands for each of the user's alarms. Phone-local.
    public private(set) var links: [UUID: UUID] = [:]
    /// False when the links file exists but could not be read; reconcile then cancels nothing.
    private var linksKnown = true
    private var tail: Task<Void, Never>?

    public init(scheduler: any AlarmScheduling, linksFile: JSONFile<[UUID: UUID]>? = nil) {
        self.scheduler = scheduler
        self.linksFile = linksFile
        do {
            links = try linksFile?.read() ?? [:]
        } catch {
            linksKnown = false
        }
    }

    /// Cancels the alarm's current system alarm, then schedules a fresh one if it is enabled.
    public func apply(_ alarm: AlarmDefinition) async throws {
        try await serially { try await self.applyNow(alarm) }
    }

    public func remove(_ alarmID: UUID) async throws {
        try await serially { await self.cancelLink(for: alarmID) }
    }

    /// Cancels every user alarm in the system that no enabled alarm stands behind, and returns the
    /// enabled alarms whose system alarm has gone, for example a one-off alarm that already rang.
    /// Throws `AlarmSyncError.linksUnreadable`, changing nothing, when the links could not be read.
    public func reconcile(_ document: AlarmDocument) async throws -> Set<UUID> {
        try await serially { try await self.reconcileNow(document) }
    }

    private func applyNow(_ alarm: AlarmDefinition) async throws {
        await cancelLink(for: alarm.id)
        guard alarm.settings.isEnabled else { return }
        let systemID = UUID()
        try await scheduler.schedule(id: systemID, alarm: alarm.settings)
        links[alarm.id] = systemID
        do {
            try save()
        } catch {
            // An alarm nobody can find again would ring with no way to switch it off in Dawn.
            try? await scheduler.cancel(id: systemID)
            links[alarm.id] = nil
            throw error
        }
    }

    private func reconcileNow(_ document: AlarmDocument) async throws -> Set<UUID> {
        guard linksKnown else { throw AlarmSyncError.linksUnreadable }
        let system = try await scheduler.userAlarmIDs()
        let enabled = Set(document.alarms.filter(\.settings.isEnabled).map(\.id))
        links = links.filter { enabled.contains($0.key) }
        for stray in system.subtracting(links.values) {
            try? await scheduler.cancel(id: stray)
        }
        let lost = enabled.filter { id in links[id].map { !system.contains($0) } ?? true }
        for id in lost { links[id] = nil }
        try? save()
        return lost
    }

    private func cancelLink(for alarmID: UUID) async {
        guard let systemID = links[alarmID] else { return }
        try? await scheduler.cancel(id: systemID)
        links[alarmID] = nil
        try? save()
    }

    private func serially<T: Sendable>(_ work: @escaping @Sendable () async throws -> T) async throws -> T {
        let previous = tail
        let task = Task<T, any Error> {
            await previous?.value
            return try await work()
        }
        tail = Task { _ = try? await task.value }
        return try await task.value
    }

    private func save() throws {
        try linksFile?.write(links)
        linksKnown = true
    }
}
