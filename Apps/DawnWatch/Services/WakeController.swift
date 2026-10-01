import DawnCore
import DawnHealth
import DawnSync
import DawnWrist
import Foundation
import Observation

/// Arms the wake window whenever the app becomes active, runs it when watchOS relaunches the app at
/// its start, wakes the wearer, and tells the phone how it went.
@MainActor
@Observable
final class WakeController {
    private(set) var arming: WakeArming
    private(set) var log: WakeLog
    /// The window the next activation would arm, for "Nothing to arm".
    private(set) var plan: WakePlan?
    @ObservationIgnored let session = ExtendedRuntimeWakeSession()
    @ObservationIgnored let motion: any MotionStream
    @ObservationIgnored let heart: any HeartRateStream
    @ObservationIgnored let channel: any WakeOutcomeChannel
    @ObservationIgnored let alarms: WatchAlarmStore
    @ObservationIgnored private let armingFile: JSONFile<WakeArming>
    @ObservationIgnored private let logFile: JSONFile<WakeLog>
    @ObservationIgnored var monitor: WakeMonitor?
    @ObservationIgnored var sensing: [Task<Void, Never>] = []
    @ObservationIgnored var firedAt: Date?

    init(alarms: WatchAlarmStore, channel: any WakeOutcomeChannel, motion: any MotionStream, heart: any HeartRateStream, folder: URL) {
        self.alarms = alarms
        self.channel = channel
        self.motion = motion
        self.heart = heart
        armingFile = JSONFile(url: folder.appending(path: "wake-arming.json"))
        logFile = JSONFile(url: folder.appending(path: "wake-log.json"))
        // Unreadable state starts afresh: at worst a window is armed again, and the phone's alarm stands.
        arming = (try? armingFile.read()) ?? WakeArming()
        log = (try? logFile.read()) ?? WakeLog()
    }

    /// Follows the session for the app's life.
    func run() async {
        for await event in session.events { await handle(event) }
    }

    /// The app is active: arm the next window if it is not armed yet, and settle the nudge.
    func activate(now: Date = Date()) async {
        plan = WakePlan(alarms: alarms.alarms, now: now, completed: arming.completedRing, calendar: .current)
        if let next = arming.toArm(plan, sessionPending: session.isPending) {
            if firedAt != nil {
                // Opened from the wake alert: that window is over, and the next one replaces it.
                await endSensing()
                monitor = nil
                firedAt = nil
            }
            session.schedule(at: next.start(at: now))
            arming.armed = next
        } else if plan == nil, arming.armed != nil, firedAt == nil {
            session.cancel()
            arming.armed = nil
        }
        save()
        await refreshNudge(now: now)
    }

    /// Offers the bedtime reminder and the Smart Stack widget only while the next window is unarmed.
    func refreshNudge(now: Date = Date()) async {
        plan = WakePlan(alarms: alarms.alarms, now: now, completed: arming.completedRing, calendar: .current)
        let nudge = BedtimeNudge.date(for: plan, armedRing: arming.armed?.windowEnd, now: now)
        await BedtimeReminder.schedule(at: nudge, title: WakeCopy.nudgeTitle, body: WakeCopy.nudgeBody)
        await WakeRelevance.update(nudge: nudge, windowStart: plan?.windowStart)
    }

    func save() {
        try? armingFile.write(arming)
        try? logFile.write(log)
    }

    func record(_ outcome: WakeOutcome) {
        log.record(outcome)
        save()
        channel.send(outcome)
    }

    func setArming(_ change: (inout WakeArming) -> Void) {
        change(&arming)
        save()
    }
}
