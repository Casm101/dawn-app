import DawnCore
import Foundation
import Observation

/// The Watch's wake window from arming to outcome: arms the next ring whenever the app is active,
/// follows edits to its alarm, runs the window when the session starts, wakes the wearer, and hands
/// the outcome on. Every platform piece sits behind a protocol, so this is tested with fakes.
@MainActor
@Observable
public final class WakeCoordinator {
    public private(set) var arming: WakeArming
    public private(set) var log: WakeLog
    /// The window the next activation would arm; nil is "Nothing to arm".
    public private(set) var plan: WakePlan?
    /// True after the system refused to start the last session it was asked for.
    public private(set) var armFailed = false
    @ObservationIgnored let session: any WakeSessionControl
    @ObservationIgnored let motion: any MotionStream
    @ObservationIgnored let heart: any HeartRateStream
    @ObservationIgnored let nudges: any WakeNudging
    @ObservationIgnored let alarms: @MainActor () -> [AlarmDefinition]
    @ObservationIgnored let send: @MainActor (WakeOutcome) -> Void
    @ObservationIgnored let isActive: @MainActor () -> Bool
    @ObservationIgnored let clock: @MainActor () -> Date
    @ObservationIgnored let calendar: Calendar
    @ObservationIgnored let checkInterval: Duration
    @ObservationIgnored private let armingFile: JSONFile<WakeArming>?
    @ObservationIgnored private let logFile: JSONFile<WakeLog>?
    @ObservationIgnored var monitor: WakeMonitor?
    @ObservationIgnored var sensing: [Task<Void, Never>] = []
    @ObservationIgnored var firedAt: Date?
    /// The step running now; each step waits for the one before it.
    @ObservationIgnored var queue: Task<Void, Never>?

    public init(
        session: any WakeSessionControl, motion: any MotionStream, heart: any HeartRateStream, nudges: any WakeNudging,
        alarms: @escaping @MainActor () -> [AlarmDefinition], send: @escaping @MainActor (WakeOutcome) -> Void,
        isActive: @escaping @MainActor () -> Bool, folder: URL?, clock: @escaping @MainActor () -> Date = { Date() },
        calendar: Calendar = .current, checkInterval: Duration = .seconds(Tuning.Wake.checkInterval)
    ) {
        (self.session, self.motion, self.heart, self.nudges) = (session, motion, heart, nudges)
        (self.alarms, self.send, self.isActive, self.clock) = (alarms, send, isActive, clock)
        (self.calendar, self.checkInterval) = (calendar, checkInterval)
        armingFile = folder.map { JSONFile(url: $0.appending(path: "wake-arming.json")) }
        logFile = folder.map { JSONFile(url: $0.appending(path: "wake-log.json")) }
        // Unreadable state starts afresh: at worst a window is armed again; the phone's alarm stands.
        arming = (try? armingFile?.read()) ?? WakeArming()
        log = (try? logFile?.read()) ?? WakeLog()
    }

    /// Follows the session for the app's life.
    public func run() async {
        for await event in session.events { await serially { await self.handle(event) } }
    }

    /// The app is in the foreground: arm first, then ask for heart rate and the reminder's permission
    /// while a prompt can show, so an unanswered prompt never holds up arming.
    public func activate() async {
        await follow()
        _ = await heart.authorize()
        await nudges.authorize()
    }

    /// Brings the armed window in line with the alarms: a window whose alarm was switched off,
    /// moved or deleted is stood down, and, in the foreground, the next ring is armed.
    public func follow() async {
        await serially { await self.followNow() }
    }

    /// `follow` without waiting its turn, for steps already running in order. `arm` is false after a
    /// window ends, so a refused start is not retried until the app is opened again.
    func followNow(arm: Bool = true) async {
        let now = clock(), current = alarms()
        plan = WakePlan(alarms: current, now: now, completed: arming.completedRing, calendar: calendar)
        if let armed = arming.armed, firedAt == nil, !armed.isCurrent(in: current, calendar: calendar) {
            session.cancel()
            await stopWindow()
            arming.armed = nil
        }
        if arm, isActive(), let next = arming.toArm(plan, sessionPending: session.isPending) {
            await stopWindow()
            await session.schedule(at: next.start(at: now))
            arming.armed = next
            armFailed = false
        }
        save()
        await refreshNudge()
    }

    /// Books a bedtime reminder for every unarmed ring in `Tuning.Wake.nudgeHorizon`, so they keep
    /// coming while the app stays closed, and offers the Smart Stack card while the next is unarmed.
    func refreshNudge() async {
        let now = clock(), ring = arming.armed?.windowEnd
        let coming = WakePlan.upcoming(
            alarms: alarms(), now: now, completed: arming.completedRing, within: Tuning.Wake.nudgeHorizon, calendar: calendar
        )
        await nudges.remind(at: coming.compactMap { BedtimeNudge.date(for: $0, armedRing: ring, now: now) })
        await nudges.offerWidget(during: BedtimeNudge.relevance(for: coming.first, armedRing: ring, now: now))
    }

    func record(_ outcome: WakeOutcome) {
        log.record(outcome)
        save()
        send(outcome)
    }

    func save() {
        try? armingFile?.write(arming)
        try? logFile?.write(log)
    }

    func update(_ change: (inout WakeArming) -> Void) {
        change(&arming)
        save()
    }

    func noteFailure(_ failed: Bool) { armFailed = failed }
}
