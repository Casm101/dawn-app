import DawnCore
import Foundation
import Observation

/// Keeps the pending reminders in line with the coming week's schedule and the habit settings, one
/// change at a time, and asks for notification permission when a reminder is first turned on. The
/// system refuses reminders added before permission is given, so they are added again once it is.
/// What was planned and what already went off is saved, so a habit fires at most once a day even
/// across launches.
@MainActor
@Observable
final class HabitReminderScheduler {
    /// True when the user has turned notifications off for Dawn in Settings.
    private(set) var isDenied = false
    @ObservationIgnored private let center: NotificationReminderCenter
    @ObservationIgnored private let file: JSONFile<HabitReminderLog>
    @ObservationIgnored private var log: HabitReminderLog
    @ObservationIgnored private var inputs: (days: [DateInterval], settings: HabitSettings, isRated: (Date) -> Bool)?
    @ObservationIgnored private var running: Task<Void, Never>?

    init(center: NotificationReminderCenter, file: JSONFile<HabitReminderLog>) {
        self.center = center
        self.file = file
        log = (try? file.read()) ?? HabitReminderLog()
    }

    /// Applies the plan for these days and settings. Unless `force`d, an unchanged plan is left alone.
    func update(days: [DateInterval], settings: HabitSettings, isRated: @escaping (Date) -> Bool, now: Date = Date(), force: Bool = false) {
        inputs = (days, settings, isRated)
        guard let plan = log.update(days: days, settings: settings, now: now, calendar: .current, isRated: isRated, force: force) else { return }
        try? file.write(log)
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
        if granted, let inputs { update(days: inputs.days, settings: inputs.settings, isRated: inputs.isRated, force: true) }
    }

    func refreshPermission() async {
        isDenied = await center.isDenied()
    }
}
