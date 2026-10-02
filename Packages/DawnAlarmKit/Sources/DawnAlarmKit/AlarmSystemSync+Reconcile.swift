import DawnCore
import Foundation

extension AlarmSystemSync {
    /// Cancels every user alarm in the system that no enabled alarm stands behind, and returns the
    /// enabled alarms whose system alarm has gone, for example a one-off alarm that already rang.
    /// Throws `AlarmSyncError.linksUnreadable`, changing nothing, when the links could not be read.
    public func reconcile(_ document: AlarmDocument) async throws -> Set<UUID> {
        try await serially { try await self.reconcileNow(document) }
    }

    private func reconcileNow(_ document: AlarmDocument) async throws -> Set<UUID> {
        guard linksKnown else { throw AlarmSyncError.linksUnreadable }
        try await restorePassedSkips(document)
        let system = try await scheduler.userAlarmIDs()
        let enabled = Set(document.alarms.filter(\.settings.isEnabled).map(\.id))
        links = links.filter { enabled.contains($0.key) }
        for stray in system.subtracting(links.values) {
            try? await scheduler.cancel(id: stray)
        }
        // An alarm whose ring is stood down may have nothing scheduled until that ring has passed.
        let lost = enabled.filter { id in
            skips[id] == nil && (links[id].map { !system.contains($0) } ?? true)
        }
        for id in lost { links[id] = nil }
        try? save()
        return lost
    }
}
