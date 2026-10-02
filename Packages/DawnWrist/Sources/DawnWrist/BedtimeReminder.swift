#if canImport(UserNotifications)
import Foundation
import UserNotifications

/// The local notifications that remind the wearer to open Dawn and arm the night's window, one
/// for each unarmed ring to come.
public enum BedtimeReminder {
    private static let prefix = "dawn.bedtime-nudge"

    /// Asks the first time; afterwards returns at once with the stored answer.
    public static func authorize() async {
        _ = try? await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound])
    }

    /// Replaces every pending reminder with one at each of `dates`. Never asks for permission, so it
    /// cannot wait on a prompt; without permission nothing is scheduled.
    public static func schedule(at dates: [Date], title: String, body: String) async {
        let center = UNUserNotificationCenter.current()
        let pending = await center.pendingNotificationRequests().map(\.identifier).filter { $0.hasPrefix(prefix) }
        center.removePendingNotificationRequests(withIdentifiers: pending)
        guard !dates.isEmpty, await center.notificationSettings().authorizationStatus == .authorized else { return }
        for date in dates {
            let content = UNMutableNotificationContent()
            content.title = title
            content.body = body
            let parts = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
            let request = UNNotificationRequest(
                identifier: "\(prefix).\(Int(date.timeIntervalSinceReferenceDate))", content: content,
                trigger: UNCalendarNotificationTrigger(dateMatching: parts, repeats: false)
            )
            try? await center.add(request)
        }
    }
}
#endif
