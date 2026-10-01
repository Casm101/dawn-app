import DawnCore
import DawnHealth
import DawnWrist
import Foundation

extension WakeController {
    func handle(_ event: WakeSessionEvent) async {
        switch event {
        case .started(let expires):
            await begin(sessionEnds: expires)
        case .willExpire:
            if let trigger = await monitor?.expiring() { await fire(trigger) }
        case .ended:
            await endSensing()
            if firedAt == nil, let outcome = await monitor?.outcome(result: .sessionEnded, firedAt: nil) { record(outcome) }
            let woke = firedAt != nil
            setArming { arming in
                if woke { arming.woke() } else { arming.ended() }
            }
            monitor = nil
            firedAt = nil
            await refreshNudge()
        }
    }

    /// The window has begun: feed motion and heart rate into a fresh monitor and check it often.
    private func begin(sessionEnds: Date?) async {
        guard let plan = arming.armed, monitor == nil else { return }
        let monitor = WakeMonitor(plan: plan, start: Date(), sessionEnds: sessionEnds)
        self.monitor = monitor
        firedAt = nil
        let motionSamples = await motion.start()
        let heartSamples = await heart.authorize() ? await heart.start() : AsyncStream { $0.finish() }
        sensing = [
            Task { for await sample in motionSamples { await monitor.ingest(sample) } },
            Task { for await sample in heartSamples { await monitor.ingest(sample) } },
            Task { [weak self] in
                while !Task.isCancelled {
                    try? await Task.sleep(for: .seconds(Tuning.Wake.checkInterval))
                    if let trigger = await monitor.tick(at: Date()) { await self?.fire(trigger) }
                }
            },
        ]
    }

    /// Wakes the wearer, and tells the phone at once so its alarm can stand down.
    func fire(_ trigger: WakeTrigger) async {
        guard firedAt == nil, let monitor else { return }
        let now = Date()
        firedAt = now
        session.wake()
        // Done for this ring at once, so opening Dawn from the alert arms the following night.
        setArming { $0.completedRing = $0.armed?.windowEnd ?? $0.completedRing }
        await endSensing()
        record(await monitor.outcome(result: trigger.isEarly ? .wokeEarly : .wokeAtEnd, firedAt: now))
    }

    func endSensing() async {
        sensing.forEach { $0.cancel() }
        sensing = []
        await motion.stop()
        await heart.stop()
    }
}
