#if canImport(WatchConnectivity)
import DawnCore
import Foundation
import WatchConnectivity

extension WatchConnectivityChannel {
    public func publish(_ document: AlarmDocument) throws {
        let context = ChannelPayload(document: document).dictionary
        try WCSession.default.updateApplicationContext(context)
        #if os(watchOS)
        // Reachability can be wrong; the context above still arrives when the message does not.
        if WCSession.default.isReachable {
            WCSession.default.sendMessage(context, replyHandler: nil, errorHandler: nil)
        }
        #endif
    }

    public func acknowledge(_ revision: Int) {
        sendLiveOrQueued(ChannelPayload(acknowledged: revision), expectsReply: false)
    }

    public func send(_ outcome: WakeOutcome) {
        sendLiveOrQueued(ChannelPayload(outcome: outcome), expectsReply: true)
    }

    /// A message while the other app can be reached, queued user info otherwise or when the message
    /// fails. With a reply expected, no reply counts as a failure.
    private func sendLiveOrQueued(_ payload: ChannelPayload, expectsReply: Bool) {
        let session = WCSession.default
        guard session.activationState == .activated else { return }
        guard session.isReachable else {
            session.transferUserInfo(payload.dictionary)
            return
        }
        let fallback: @Sendable (any Error) -> Void = { _ in WCSession.default.transferUserInfo(payload.dictionary) }
        session.sendMessage(payload.dictionary, replyHandler: expectsReply ? { _ in } : nil, errorHandler: fallback)
    }

    #if os(watchOS)
    /// Waits, a short while at most, until the system has handed over what it held for the app, so a
    /// background refresh is not ended before the phone's copy lands.
    public func waitForPendingContent() async {
        await activate()
        for _ in 0..<40 where WCSession.default.hasContentPending {
            try? await Task.sleep(for: .milliseconds(500))
        }
    }
    #endif
}
#endif
