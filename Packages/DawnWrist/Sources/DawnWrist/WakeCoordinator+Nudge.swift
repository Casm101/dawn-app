import DawnCore
import Foundation

extension WakeCoordinator {
    /// Books a bedtime reminder for every unarmed ring in `Tuning.Wake.nudgeHorizon`, so they keep
    /// coming while the app stays closed, and offers the Smart Stack card while the next is unarmed.
    func refreshNudge() async {
        let now = clock(), ring = arming.armed?.windowEnd
        let coming = WakePlan.upcoming(
            alarms: alarms(), now: now, completed: arming.completedRing, within: Tuning.Wake.nudgeHorizon, calendar: calendar
        )
        await nudges.remind(at: coming.compactMap { BedtimeNudge.date(for: $0, armedRing: ring, now: now) })
        // Handed over outside the queue: the system can take a long time to answer (on the simulator
        // it never does), which must not hold up the next window step. Hand-overs stay in order, and
        // one that is no longer the latest by its turn is skipped.
        let relevance = BedtimeNudge.relevance(for: coming.first, armedRing: ring, now: now)
        widgetGeneration += 1
        let generation = widgetGeneration, previous = widgetUpdate
        widgetUpdate = Task { [nudges] in
            await previous?.value
            guard generation == self.widgetGeneration else { return }
            await nudges.offerWidget(during: relevance)
        }
    }
}
