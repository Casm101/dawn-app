#if os(watchOS)
import DawnCore
import Foundation
import WatchKit

/// One smart-alarm extended runtime session (WakeTF's ExtendedRuntimeController, MIT): scheduled
/// from the foreground, picked up again when watchOS relaunches the app at the window's start, and
/// the only thing allowed to play the wake haptic.
@MainActor
public final class ExtendedRuntimeWakeSession: NSObject, WakeSessionControl, WKExtendedRuntimeSessionDelegate {
    public let events: AsyncStream<WakeSessionEvent>
    private let sink: AsyncStream<WakeSessionEvent>.Continuation
    private var session: WKExtendedRuntimeSession?
    /// Waiting for a replaced session to finish ending before the next one starts.
    private var ending: CheckedContinuation<Void, Never>?

    override public init() {
        (events, sink) = AsyncStream.makeStream()
        super.init()
    }

    /// True while a session is waiting for its start or running.
    public var isPending: Bool {
        guard let session else { return false }
        return session.state == .scheduled || session.state == .running
    }

    /// Schedules a session for `date`, after any earlier one from this launch has finished ending
    /// (or a few seconds have passed). Only works while the app is active; a session from an earlier
    /// launch is replaced by the system when a new one is scheduled.
    public func schedule(at date: Date) async {
        if let old = session, old.state == .scheduled || old.state == .running {
            await withCheckedContinuation { continuation in
                ending = continuation
                old.invalidate()
                Task { @MainActor in
                    try? await Task.sleep(for: .seconds(Tuning.Wake.replaceTimeout))
                    self.finishEnding()
                }
            }
        }
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

    /// Passes on news from the current session only: a session being replaced reports only that it
    /// has ended, to the schedule waiting for it, and never ends the new one.
    nonisolated private func report(_ event: WakeSessionEvent, from source: ObjectIdentifier) {
        Task { @MainActor in
            guard let session = self.session, ObjectIdentifier(session) == source else { return }
            if self.ending != nil {
                if case .ended = event { self.finishEnding() }
                return
            }
            self.sink.yield(event)
        }
    }

    private func finishEnding() {
        ending?.resume()
        ending = nil
    }
}
#endif
