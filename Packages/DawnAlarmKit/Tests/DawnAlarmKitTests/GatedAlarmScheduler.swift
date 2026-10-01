import DawnCore
import Foundation
@testable import DawnAlarmKit

/// A scheduler whose schedule calls wait until the test opens the gate, to force interleaving.
actor GatedAlarmScheduler: AlarmScheduling {
    private var stored: [UUID: AlarmSettings] = [:]
    private var held: [CheckedContinuation<Void, Never>] = []
    private var arrivals: [CheckedContinuation<Void, Never>] = []
    private var isOpen = false

    func schedule(id: UUID, alarm: AlarmSettings) async throws {
        if !isOpen {
            arrivals.forEach { $0.resume() }
            arrivals = []
            await withCheckedContinuation { held.append($0) }
        }
        stored[id] = alarm
    }

    func schedule(id: UUID, fireDate: Date) async throws -> ScheduledAlarm { ScheduledAlarm(id: id, fireDate: fireDate) }
    func cancel(id: UUID) async throws { stored[id] = nil }
    func scheduled() async -> [ScheduledAlarm] { [] }
    func systemIDs() async throws -> Set<UUID> { Set(stored.keys) }

    /// Returns once a schedule call is waiting at the gate.
    func waitForArrival() async {
        guard held.isEmpty else { return }
        await withCheckedContinuation { arrivals.append($0) }
    }

    func open() {
        isOpen = true
        held.forEach { $0.resume() }
        held = []
    }
}
