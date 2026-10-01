#if canImport(WatchConnectivity)
import DawnCore
import Foundation
import Synchronization
import WatchConnectivity

/// The alarm document over WatchConnectivity: the document as the application context, so only the
/// newest copy is delivered, even to an app that is not running. The Watch also sends the document as
/// a message while the phone is reachable, which wakes the phone app so its system alarm moves without
/// waiting for the app to be opened. Acknowledgements go as a message while the other app can be
/// reached and as queued user info otherwise, or when the message fails.
public final class WatchConnectivityChannel: NSObject, AlarmDocumentChannel, WCSessionDelegate {
    public let documents: AsyncStream<AlarmDocument>
    public let acknowledgements: AsyncStream<Int>
    private let documentSink: AsyncStream<AlarmDocument>.Continuation
    private let ackSink: AsyncStream<Int>.Continuation
    /// Callers waiting for the session to activate.
    private let waiting = Mutex<[CheckedContinuation<Void, Never>]>([])

    override public init() {
        (documents, documentSink) = AsyncStream.makeStream()
        (acknowledgements, ackSink) = AsyncStream.makeStream()
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

    public func publish(_ document: AlarmDocument) throws {
        let context: [String: Any] = [Keys.document: try JSONEncoder().encode(document)]
        try WCSession.default.updateApplicationContext(context)
        #if os(watchOS)
        // Reachability can be wrong; the context above still arrives when the message does not.
        if WCSession.default.isReachable {
            WCSession.default.sendMessage(context, replyHandler: nil, errorHandler: nil)
        }
        #endif
    }

    public func acknowledge(_ revision: Int) {
        let session = WCSession.default
        guard session.activationState == .activated else { return }
        guard session.isReachable else {
            session.transferUserInfo([Keys.acknowledged: revision])
            return
        }
        session.sendMessage([Keys.acknowledged: revision], replyHandler: nil) { _ in
            WCSession.default.transferUserInfo([Keys.acknowledged: revision])
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

    public func session(_ session: WCSession, didReceiveUserInfo userInfo: [String: Any] = [:]) {
        receive(userInfo)
    }

    #if os(iOS)
    public func sessionDidBecomeInactive(_ session: WCSession) {}
    public func sessionDidDeactivate(_ session: WCSession) { session.activate() }
    #endif

    /// Takes a document or an acknowledgement, however it arrived.
    private func receive(_ payload: [String: Any]) {
        if let revision = payload[Keys.acknowledged] as? Int { ackSink.yield(revision) }
        guard let data = payload[Keys.document] as? Data,
              let document = try? JSONDecoder().decode(AlarmDocument.self, from: data) else { return }
        documentSink.yield(document)
    }

    private enum Keys {
        static let document = "document"
        static let acknowledged = "acknowledged"
    }
}
#endif
