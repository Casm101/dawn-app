#if canImport(UserNotifications)
import Foundation
import UserNotifications

/// The one local notification that reminds the wearer to open Dawn and arm tonight's window.
public enum BedtimeReminder {
    private static let identifier = "dawn.bedtime-nudge"

    /// Asks the first time; afterwards returns at once with the stored answer.
    public static func authorize() async {
        _ = try? await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound])
    }

    /// Replaces any pending reminder with one at `date`, or just removes it when `date` is nil.
    public static func schedule(at date: Date?, title: String, body: String) async {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [identifier])
        guard let date, (try? await center.requestAuthorization(options: [.alert, .sound])) == true else { return }
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        let parts = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let request = UNNotificationRequest(
            identifier: identifier, content: content, trigger: UNCalendarNotificationTrigger(dateMatching: parts, repeats: false)
        )
        try? await center.add(request)
    }
}
#endif
