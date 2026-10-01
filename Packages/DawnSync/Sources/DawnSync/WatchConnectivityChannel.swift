#if canImport(WatchConnectivity)
import DawnCore
import Foundation
import Synchronization
import WatchConnectivity

/// The alarm document over WatchConnectivity: the document as the application context, so only the
/// newest copy is delivered, even to an app that is not running; acknowledgements as queued user info.
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
        try WCSession.default.updateApplicationContext([Keys.document: JSONEncoder().encode(document)])
    }

    public func acknowledge(_ revision: Int) {
        guard WCSession.default.activationState == .activated else { return }
        WCSession.default.transferUserInfo([Keys.acknowledged: revision])
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

    public func session(_ session: WCSession, didReceiveUserInfo userInfo: [String: Any] = [:]) {
        if let revision = userInfo[Keys.acknowledged] as? Int { ackSink.yield(revision) }
    }

    #if os(iOS)
    public func sessionDidBecomeInactive(_ session: WCSession) {}
    public func sessionDidDeactivate(_ session: WCSession) { session.activate() }
    #endif

    private func receive(_ context: [String: Any]) {
        guard let data = context[Keys.document] as? Data,
              let document = try? JSONDecoder().decode(AlarmDocument.self, from: data) else { return }
        documentSink.yield(document)
    }

    private enum Keys {
        static let document = "document"
        static let acknowledged = "acknowledged"
    }
}
#endif
