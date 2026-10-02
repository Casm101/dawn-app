import DawnCore
import Foundation

extension WakeCoordinator {
    func handle(_ event: WakeSessionEvent) async {
        switch event {
        case .started(let expires):
            await begin(sessionEnds: expires)
        case .willExpire:
            if let trigger = await monitor?.expiring() { await fire(trigger) }
        case .ended(let failed):
            // A newer session is already waiting or running, so this end is the one it replaced.
            guard !session.isPending else { return }
            let ran = monitor != nil, woke = firedAt != nil
            await stopWindow()
            update { arming in if woke { arming.woke() } else { arming.ended() } }
            noteFailure(failed && !ran && !woke)
            firedAt = nil
            // The plan is worked out again, since after a relaunch it was never made and after a
            // wake it still names the ring just done; the next night's reminder comes from it.
            await followNow(arm: false)
        }
    }

    /// The window has begun. A session whose plan is gone or stale is ended at once rather than left
    /// to expire silently; otherwise the deadline check starts first, then motion, then heart rate
    /// if its question was already answered in the foreground.
    private func begin(sessionEnds: Date?) async {
        guard let plan = arming.armed, plan.isCurrent(in: alarms(), calendar: calendar) else {
            session.cancel()
            return
        }
        guard monitor == nil else { return }
        let monitor = WakeMonitor(plan: plan, start: clock(), sessionEnds: sessionEnds)
        self.monitor = monitor
        firedAt = nil
        let interval = checkInterval
        sensing.append(Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: interval)
                guard let self else { return }
                if let trigger = await monitor.tick(at: self.clock()) { await self.serially { await self.fire(trigger) } }
            }
        })
        let motionSamples = await motion.start()
        sensing.append(Task { for await sample in motionSamples { await monitor.ingest(sample) } })
        guard await heart.canRead() else { return }
        let heartSamples = await heart.start()
        sensing.append(Task { for await sample in heartSamples { await monitor.ingest(sample) } })
    }

    /// Wakes the wearer and tells the phone at once, so its alarm can stand down.
    func fire(_ trigger: WakeTrigger) async {
        guard firedAt == nil, let monitor else { return }
        let now = clock()
        firedAt = now
        session.wake()
        // Done for this ring at once, so opening Dawn from the alert arms the following night.
        update { $0.completedRing = $0.armed?.windowEnd ?? $0.completedRing }
        await endSensing()
        record(await monitor.outcome(result: trigger.isEarly ? .wokeEarly : .wokeAtEnd, firedAt: now))
    }

    /// Ends the current window's sensing; one that never fired is recorded as ended.
    func stopWindow() async {
        guard let monitor else { return }
        if firedAt == nil { record(await monitor.outcome(result: .sessionEnded, firedAt: nil)) }
        await endSensing()
        self.monitor = nil
        firedAt = nil
    }

    private func endSensing() async {
        sensing.forEach { $0.cancel() }
        sensing = []
        await motion.stop()
        await heart.stop()
    }
}
