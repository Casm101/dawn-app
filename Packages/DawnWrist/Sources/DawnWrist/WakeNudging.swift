import Foundation

/// The bedtime reminder and the Smart Stack card. UserNotifications and AppIntents sit behind it
/// on the Watch; tests use a fake.
public protocol WakeNudging: Sendable {
    /// Replaces the pending reminders with one at each of `dates`; an empty list removes them all.
    func remind(at dates: [Date]) async
    /// Makes the "Arm tonight" card relevant during `interval`, or nowhere when nil.
    func offerWidget(during interval: DateInterval?) async
    /// Asks for permission to post the reminder, while the app is in the foreground and a prompt can show.
    func authorize() async
}
