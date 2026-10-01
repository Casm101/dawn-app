import DawnCore
import Foundation
import Observation

/// Keeps the pending reminders in line with the day's schedule and the habit settings, one change
/// at a time, and asks for notification permission when a reminder is first turned on. The system
/// refuses reminders added before permission is given, so they are added again once it is.
@MainActor
@Observable
final class HabitReminderScheduler {
    /// True when the user has turned notifications off for Dawn in Settings.
    private(set) var isDenied = false
    @ObservationIgnored private let center: NotificationReminderCenter
    @ObservationIgnored private var applied: [HabitReminder]?
    @ObservationIgnored private var days: [EnergySchedule] = []
    @ObservationIgnored private var settings = HabitSettings()
    @ObservationIgnored private var running: Task<Void, Never>?

    init(center: NotificationReminderCenter) {
        self.center = center
    }

    /// Applies the plan for these days and settings. Unless `force`d, an unchanged plan is left alone.
    func update(days: [EnergySchedule], settings: HabitSettings, now: Date = Date(), force: Bool = false) {
        self.days = days
        self.settings = settings
        let plan = HabitReminderPlan.reminders(days: days, settings: settings, now: now, calendar: .current)
        guard force || plan != applied else { return }
        applied = plan
        let previous = running
        running = Task { [center] in
            await previous?.value
            await HabitReminderSync.apply(plan, to: center)
        }
    }

    /// Asks the first time; afterwards notes whether the answer was no. Once allowed, the plan is
    /// applied again, since anything added while waiting for the answer was refused.
    func requestPermission() async {
        let granted = await center.requestPermission()
        isDenied = granted ? false : await center.isDenied()
        if granted { update(days: days, settings: settings, force: true) }
    }

    func refreshPermission() async {
        isDenied = await center.isDenied()
    }
}
