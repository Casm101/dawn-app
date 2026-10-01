import DawnCore
import Foundation

extension AlarmLibrary {
    /// Takes a document merged with the Watch's copy: saves it, reschedules each alarm whose settings
    /// changed, and removes system alarms for alarms that are gone. Nothing is sent back from here.
    public func applyRemote(_ merged: AlarmDocument) async {
        guard !isReadOnly else { return }
        let previous = document
        document = merged
        persist()
        for alarm in merged.alarms where previous.alarm(alarm.id)?.settings != alarm.settings {
            do {
                try await sync.apply(alarm)
            } catch {
                problem = .couldNotSchedule(alarm.settings.time)
            }
        }
        for alarm in previous.alarms where merged.alarm(alarm.id) == nil {
            try? await sync.remove(alarm.id)
        }
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
    public func systemLink(for id: UUID) async -> UUID? {
        await sync.links[id]
    }
}
