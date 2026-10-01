import DawnCore
import Foundation
import UserNotifications

/// Habit reminders as local notifications, and what happens when one is tapped. Holds no state of
/// its own: the system's notification centre is the record. No package is named for UserNotifications,
/// so, like `SoundPreview`, this thin adapter is an app service; the planning it carries out lives in
/// `DawnCore` behind `HabitReminderCenter`, with a fake in its tests.
final class NotificationReminderCenter: NSObject, HabitReminderCenter, UNUserNotificationCenterDelegate, Sendable {
    private let opened: @Sendable (Habit) -> Void

    init(opened: @escaping @Sendable (Habit) -> Void) {
        self.opened = opened
    }

    func pending() async -> [HabitReminder] {
        await UNUserNotificationCenter.current().pendingNotificationRequests().compactMap { request in
            guard request.identifier.hasPrefix(Tuning.Habits.reminderPrefix),
                  let habit = (request.content.userInfo[Self.habitKey] as? String).flatMap(Habit.init(rawValue:)),
                  let parts = request.content.userInfo[Self.dayKey] as? [Int], parts.count == 3,
                  let date = (request.trigger as? UNCalendarNotificationTrigger)?.nextTriggerDate() else { return nil }
            let day = CalendarDay(year: parts[0], month: parts[1], day: parts[2])
            return HabitReminder(id: request.identifier, habit: habit, day: day, date: date)
        }
    }

    func pendingIDs() async -> [String] {
        await UNUserNotificationCenter.current().pendingNotificationRequests().map(\.identifier)
            .filter { $0.hasPrefix(Tuning.Habits.reminderPrefix) }
    }

    func add(_ reminder: HabitReminder) async {
        let content = UNMutableNotificationContent()
        content.title = HabitText.name(reminder.habit)
        content.body = HabitText.reminder(reminder.habit)
        content.sound = .default
        content.userInfo = [Self.habitKey: reminder.habit.rawValue, Self.dayKey: [reminder.day.year, reminder.day.month, reminder.day.day]]
        let when = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: reminder.date)
        let request = UNNotificationRequest(
            identifier: reminder.id, content: content, trigger: UNCalendarNotificationTrigger(dateMatching: when, repeats: false)
        )
        try? await UNUserNotificationCenter.current().add(request)
    }

    func remove(_ ids: [String]) async {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ids)
    }

    /// Whether Dawn may post reminders, asking the first time.
    func requestPermission() async -> Bool {
        (try? await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound])) ?? false
    }

    func isDenied() async -> Bool {
        await UNUserNotificationCenter.current().notificationSettings().authorizationStatus == .denied
    }

    // The completion-handler forms, not the async ones: those finish on a background thread, and
    // UIKit requires the tap's completion on the thread it called from.
    func userNotificationCenter(
        _ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        if let habit = (response.notification.request.content.userInfo[Self.habitKey] as? String).flatMap(Habit.init(rawValue:)) {
            opened(habit)
        }
        completionHandler()
    }

    /// A reminder that comes while Dawn is open still shows.
    func userNotificationCenter(
        _ center: UNUserNotificationCenter, willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }

    private static let habitKey = "habit"
    private static let dayKey = "day"
}
