import Foundation
@testable import DawnCore

/// Pending reminders in memory, recording what was added and removed.
actor FakeReminderCenter: HabitReminderCenter {
    private(set) var reminders: [HabitReminder]
    /// Prefixed requests the real centre could not read back.
    private(set) var unreadable: [String]
    private(set) var added: [HabitReminder] = []
    private(set) var removed: [String] = []

    init(pending: [HabitReminder] = [], unreadable: [String] = []) {
        reminders = pending
        self.unreadable = unreadable
    }

    func pending() async -> [HabitReminder] { reminders }

    func pendingIDs() async -> [String] { reminders.map(\.id) + unreadable }

    func add(_ reminder: HabitReminder) async {
        added.append(reminder)
        reminders.removeAll { $0.id == reminder.id }
        reminders.append(reminder)
    }

    func remove(_ ids: [String]) async {
        removed += ids
        reminders.removeAll { ids.contains($0.id) }
        unreadable.removeAll { ids.contains($0) }
    }
}
