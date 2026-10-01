#if canImport(WatchConnectivity)
import DawnCore
import Foundation
import Synchronization
import WatchConnectivity

/// The alarm document over WatchConnectivity: the document as the application context, so only the
/// newest copy is delivered, even to an app that is not running. The Watch also sends the document as
/// a message while the phone is reachable, which wakes the phone app so its system alarm moves without
/// waiting for the app to be opened. Acknowledgements go as a message while the other app can be
/// reached and as queued user info otherwise, or when the message fails. A wake window's outcome
/// travels the same way, so an early wake reaches the phone before its alarm rings.
public final class WatchConnectivityChannel: NSObject, AlarmDocumentChannel, WakeOutcomeChannel, WCSessionDelegate {
    public let documents: AsyncStream<AlarmDocument>
    public let acknowledgements: AsyncStream<Int>
    public let outcomes: AsyncStream<WakeOutcome>
    private let documentSink: AsyncStream<AlarmDocument>.Continuation
    private let ackSink: AsyncStream<Int>.Continuation
    private let outcomeSink: AsyncStream<WakeOutcome>.Continuation
    /// Callers waiting for the session to activate.
    private let waiting = Mutex<[CheckedContinuation<Void, Never>]>([])

    override public init() {
        (documents, documentSink) = AsyncStream.makeStream()
        (acknowledgements, ackSink) = AsyncStream.makeStream()
        (outcomes, outcomeSink) = AsyncStream.makeStream()
        super.init()
    }

    public func activate() async {
        guard WCSession.isSupported() else { return }
        let session = WCSession.default
        if session.activationState == .activated { return }
        await withCheckedContinuation { continuation in
            waiting.withLock { $0.append(continuation) }
            session.delegate = self
            session.activate()
        }
    }

    public func counterpartAvailable() async -> Bool {
        #if os(iOS)
        WCSession.default.isPaired && WCSession.default.isWatchAppInstalled
        #else
        WCSession.default.isCompanionAppInstalled
        #endif
    }

    public func session(_ session: WCSession, activationDidCompleteWith state: WCSessionActivationState, error: (any Error)?) {
        receive(session.receivedApplicationContext)
        for continuation in waiting.withLock({ list in defer { list = [] }; return list }) { continuation.resume() }
    }

    public func session(_ session: WCSession, didReceiveApplicationContext context: [String: Any]) {
        receive(context)
    }

    public func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        receive(message)
    }

    public func session(
        _ session: WCSession, didReceiveMessage message: [String: Any], replyHandler: @escaping ([String: Any]) -> Void
    ) {
        receive(message)
        replyHandler([:])
    }

    public func session(_ session: WCSession, didReceiveUserInfo userInfo: [String: Any] = [:]) {
        receive(userInfo)
    }

    #if os(iOS)
    public func sessionDidBecomeInactive(_ session: WCSession) {}
    public func sessionDidDeactivate(_ session: WCSession) { session.activate() }
    #endif

    /// Takes whatever the payload holds, however it arrived.
    private func receive(_ dictionary: [String: Any]) {
        let payload = ChannelPayload(dictionary)
        if let revision = payload.acknowledged { ackSink.yield(revision) }
        if let document = payload.document { documentSink.yield(document) }
        if let outcome = payload.outcome { outcomeSink.yield(outcome) }
    }
}
#endif
