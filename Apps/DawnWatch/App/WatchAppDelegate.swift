import WatchKit

/// Receives the wake-window session when watchOS relaunches the app at the window's start.
final class WatchAppDelegate: NSObject, WKApplicationDelegate {
    func handle(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
        MainActor.assumeIsolated { WakeSessionInbox.shared.deliver(extendedRuntimeSession) }
    }
}
