import WatchKit

/// Hands the session watchOS relaunches the app for to whoever runs the window, even if it arrives
/// before they are ready.
@MainActor
final class WakeSessionInbox {
    static let shared = WakeSessionInbox()
    private var pending: WKExtendedRuntimeSession?
    private var handler: ((WKExtendedRuntimeSession) -> Void)?

    func deliver(_ session: WKExtendedRuntimeSession) {
        if let handler { handler(session) } else { pending = session }
    }

    func receive(_ handler: @escaping (WKExtendedRuntimeSession) -> Void) {
        self.handler = handler
        if let pending { handler(pending) }
        pending = nil
    }
}
