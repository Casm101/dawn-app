#if os(watchOS)
import DawnCore
import Foundation
import WatchKit

/// One smart-alarm extended runtime session (WakeTF's ExtendedRuntimeController, MIT): scheduled
/// from the foreground, picked up again when watchOS relaunches the app at the window's start, and
/// the only thing allowed to play the wake haptic.
@MainActor
public final class ExtendedRuntimeWakeSession: NSObject, WKExtendedRuntimeSessionDelegate {
    public let events: AsyncStream<WakeSessionEvent>
    private let sink: AsyncStream<WakeSessionEvent>.Continuation
    private var session: WKExtendedRuntimeSession?

    override public init() {
        (events, sink) = AsyncStream.makeStream()
        super.init()
    }

    /// True while a session is waiting for its start or running.
    public var isPending: Bool {
        guard let session else { return false }
        return session.state == .scheduled || session.state == .running
    }

    /// Schedules a session for `date`, replacing any earlier one. Only works while the app is active.
    public func schedule(at date: Date) {
        session?.invalidate()
        let next = WKExtendedRuntimeSession()
        next.delegate = self
        session = next
        next.start(at: date)
    }

    /// Takes the session watchOS relaunched the app for; its delegate must be set at once.
    public func attach(_ resumed: WKExtendedRuntimeSession) {
        session = resumed
        resumed.delegate = self
        if resumed.state == .running { sink.yield(.started(expires: resumed.expirationDate)) }
    }

    /// Plays the wake haptic again and again until the wearer taps Stop.
    public func wake() {
        session?.notifyUser(hapticType: .notification) { _ in Tuning.Wake.hapticRepeat }
    }

    public func cancel() {
        session?.invalidate()
    }

    nonisolated public func extendedRuntimeSessionDidStart(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
        let expires = extendedRuntimeSession.expirationDate
        report(.started(expires: expires), from: ObjectIdentifier(extendedRuntimeSession))
    }

    nonisolated public func extendedRuntimeSessionWillExpire(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
        report(.willExpire, from: ObjectIdentifier(extendedRuntimeSession))
    }

    nonisolated public func extendedRuntimeSession(
        _ extendedRuntimeSession: WKExtendedRuntimeSession,
        didInvalidateWith reason: WKExtendedRuntimeSessionInvalidationReason, error: (any Error)?
    ) {
        let failed = error != nil || reason == .error || reason == .suppressedBySystem
        report(.ended(failed: failed), from: ObjectIdentifier(extendedRuntimeSession))
    }

    /// Passes on news from the current session only: a session replaced by a newer one may still
    /// report that it ended, and that must not end the new one.
    nonisolated private func report(_ event: WakeSessionEvent, from source: ObjectIdentifier) {
        Task { @MainActor in
            guard let session = self.session, ObjectIdentifier(session) == source else { return }
            self.sink.yield(event)
        }
    }
}
#endif
