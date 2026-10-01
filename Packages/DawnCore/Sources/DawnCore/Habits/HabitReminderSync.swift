/// Brings the pending reminders in line with a plan, touching only what differs.
public enum HabitReminderSync {
    public static func apply(_ plan: [HabitReminder], to center: some HabitReminderCenter) async {
        let pending = await center.pending()
        let planned = Set(plan.map(\.id))
        let stale = await center.pendingIDs().filter { !planned.contains($0) }
        if !stale.isEmpty { await center.remove(stale) }
        let current = Set(pending)
        for reminder in plan where !current.contains(reminder) {
            await center.add(reminder)
        }
    }
}
