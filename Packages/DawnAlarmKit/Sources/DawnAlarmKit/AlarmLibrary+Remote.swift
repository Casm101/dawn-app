import DawnCore
import Foundation

extension AlarmLibrary {
    /// Takes a document merged with the Watch's copy and moves the system alarm of every alarm whose
    /// ring changed, all in one turn. An alarm the phone cannot ring as the Watch set it is switched
    /// off, as the same change made on the phone would be. Returns true when that happened, so the
    /// merged copy goes back to the Watch.
    public func applyRemote(_ merged: AlarmDocument, at now: Date) async -> Bool {
        guard !isReadOnly else { return false }
        let previous = document
        document = merged
        let changed = merged.alarms.filter { alarm in
            previous.alarm(alarm.id).map { alarm.settings.ringsDifferently(from: $0.settings) } ?? alarm.settings.isEnabled
        }.map(\.id)
        // Like a change made here, a change to how an alarm rings clears the last problem shown.
        if !changed.isEmpty { problem = nil }
        for id in changed { checkRemote(id, at: now) }
        persist()
        let gone = previous.alarms.map(\.id).filter { merged.alarm($0) == nil }
        let refused = await sync.apply(changed.compactMap { document.alarm($0) }, removing: gone)
        if !refused.isEmpty {
            for id in refused { switchOff(id, at: now) { .couldNotSchedule($0.time) } }
            persist()
        }
        return !document.sameContent(as: merged)
    }

    /// The document with a higher revision, saved, for sending to the Watch.
    public func documentForSending(at now: Date) -> AlarmDocument {
        var copy = document
        copy.bump(at: now, by: .phone)
        if !isReadOnly {
            document = copy
            persist()
        }
        return copy
    }

    /// The system alarm currently standing for an alarm, if any.
    func systemLink(for id: UUID) async -> UUID? {
        await sync.links[id]
    }

    /// Applies the rules a change made on the phone meets: no alarms without permission, no one-off
    /// too close to its time, and a note when a repeating alarm may miss its next ring.
    private func checkRemote(_ id: UUID, at now: Date) {
        guard let settings = document.alarm(id)?.settings, settings.isEnabled else { return }
        if permission == .denied {
            switchOff(id, at: now) { .couldNotSchedule($0.time) }
            return
        }
        switch AlarmOccurrence.leadTimeProblem(settings, after: now, calendar: calendar) {
        case .tooCloseToSet:
            switchOff(id, at: now) { .tooSoonToSet($0.time) }
        case .nextRingTooClose(let skipped, let following):
            problem = problem ?? .mayMissNextRing(skipped: skipped, following: following)
        case nil:
            break
        }
    }

    private func switchOff(_ id: UUID, at now: Date, because reason: (AlarmSettings) -> AlarmProblem) {
        guard var settings = document.alarm(id)?.settings else { return }
        settings.isEnabled = false
        document.save(settings, id: id, at: now, by: .phone)
        problem = reason(settings)
    }
}
