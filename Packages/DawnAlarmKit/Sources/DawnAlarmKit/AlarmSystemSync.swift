import DawnCore
import Foundation

/// Keeps the system's alarms in step with the user's list. The system never changes an alarm in
/// place: every change cancels the old system alarm and schedules a new one under a new id.
/// Operations run one at a time, so a quick on-then-off can never leave a system alarm behind.
public actor AlarmSystemSync {
    let scheduler: any AlarmScheduling
    private let linksFile: JSONFile<[UUID: UUID]>?
    /// Which system alarm currently stands for each of the user's alarms. Phone-local.
    public internal(set) var links: [UUID: UUID] = [:]
    /// False when the links file exists but could not be read; reconcile then cancels nothing.
    var linksKnown = true
    private var tail: Task<Void, Never>?
    /// Rings stood down because the Watch woke the wearer first, by alarm.
    var skips: [UUID: BackstopSkip] = [:]
    let skipsFile: JSONFile<[UUID: BackstopSkip]>?
    let clock: @Sendable () -> Date
    let calendar: Calendar

    public init(
        scheduler: any AlarmScheduling, linksFile: JSONFile<[UUID: UUID]>? = nil,
        skipsFile: JSONFile<[UUID: BackstopSkip]>? = nil, clock: @escaping @Sendable () -> Date = { Date() },
        calendar: Calendar = .current
    ) {
        self.scheduler = scheduler
        self.linksFile = linksFile
        self.skipsFile = skipsFile
        self.clock = clock
        self.calendar = calendar
        // An unreadable record of skips is dropped: the full alarms ring, which is the safe side.
        skips = (try? skipsFile?.read()) ?? [:]
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

    /// Applies the changes one merge brought, then cancels the alarms it deleted, all in one turn so
    /// a reconcile never sees half of them. Returns the alarms the system refused.
    public func apply(_ alarms: [AlarmDefinition], removing removed: [UUID]) async -> Set<UUID> {
        let refused = try? await serially {
            var refused: Set<UUID> = []
            for alarm in alarms {
                do { try await self.applyNow(alarm) } catch { refused.insert(alarm.id) }
            }
            for id in removed {
                await self.cancelLink(for: id)
                await self.dropSkip(for: id)
            }
            return refused
        }
        return refused ?? []
    }

    public func remove(_ alarmID: UUID) async throws {
        try await serially {
            await self.cancelLink(for: alarmID)
            await self.dropSkip(for: alarmID)
        }
    }

    func applyNow(_ alarm: AlarmDefinition) async throws {
        await cancelLink(for: alarm.id)
        guard alarm.settings.isEnabled else {
            await dropSkip(for: alarm.id)
            return
        }
        let systemID = UUID()
        guard try await scheduleHonouringSkip(alarm, id: systemID) else { return }
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

    func cancelLink(for alarmID: UUID) async {
        guard let systemID = links[alarmID] else { return }
        try? await scheduler.cancel(id: systemID)
        links[alarmID] = nil
        try? save()
    }

    func serially<T: Sendable>(_ work: @escaping @Sendable () async throws -> T) async throws -> T {
        let previous = tail
        let task = Task<T, any Error> {
            await previous?.value
            return try await work()
        }
        tail = Task { _ = try? await task.value }
        return try await task.value
    }

    func save() throws {
        try linksFile?.write(links)
        linksKnown = true
    }
}
