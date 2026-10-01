import DawnCore
import Foundation
import Observation

/// The user's alarms on the phone: saved as one document and kept in step with the system's alarms.
@MainActor
@Observable
public final class AlarmLibrary {
    public private(set) var document = AlarmDocument()
    public private(set) var permission: AlarmPermissionState = .notDetermined
    /// The latest thing the user should hear about, cleared by the next change.
    public private(set) var problem: AlarmProblem?
    /// True after the saved alarms could not be read. The list is then left untouched, so nothing
    /// overwrites the file and nothing cancels the alarms it describes.
    public private(set) var isReadOnly = false

    private let file: JSONFile<AlarmDocument>
    private let sync: AlarmSystemSync
    private let authorizer: any AlarmAuthorizing
    private let calendar: Calendar

    public init(
        file: JSONFile<AlarmDocument>, sync: AlarmSystemSync, authorizer: any AlarmAuthorizing,
        calendar: Calendar = .current
    ) {
        self.file = file
        self.sync = sync
        self.authorizer = authorizer
        self.calendar = calendar
    }

    public var alarms: [AlarmDefinition] { document.alarms }

    public func nextRing(after now: Date = Date()) -> Date? {
        alarms.map(\.settings).filter(\.isEnabled)
            .compactMap { AlarmOccurrence.next($0, after: now, calendar: calendar) }
            .min()
    }

    /// Reads the saved alarms and switches off any the system no longer holds. If the file cannot be
    /// read, the system's alarms are left alone rather than cancelled.
    public func load(now: Date = Date()) async {
        permission = await authorizer.state()
        do {
            let stored = try file.read() ?? AlarmDocument()
            guard stored.schemaVersion <= AlarmDocument.currentSchema else { throw CocoaError(.fileReadCorruptFile) }
            document = stored
        } catch {
            isReadOnly = true
            problem = .couldNotLoad
            return
        }
        isReadOnly = false
        let lost: Set<UUID>
        do {
            lost = try await sync.reconcile(document)
        } catch {
            problem = .couldNotCheck
            return
        }
        guard !lost.isEmpty else { return }
        for id in lost {
            guard var settings = document.alarm(id)?.settings else { continue }
            settings.isEnabled = false
            document.save(settings, id: id, at: now, by: .phone)
        }
        persist()
    }

    /// Saves the alarm and schedules it. An enabled one-off too close to its time is refused.
    public func save(_ settings: AlarmSettings, id: UUID, now: Date = Date()) async {
        guard !isReadOnly else { problem = .couldNotLoad; return }
        problem = nil
        var settings = settings
        var notice: AlarmProblem?
        if settings.isEnabled {
            switch AlarmOccurrence.leadTimeProblem(settings, after: now, calendar: calendar) {
            case .tooCloseToSet:
                problem = .tooSoonToSet(settings.time)
                return
            case .nextRingTooClose(let skipped, let following):
                notice = .mayMissNextRing(skipped: skipped, following: following)
            case nil:
                break
            }
            if permission != .authorized { permission = await authorizer.request() }
            if permission != .authorized { settings.isEnabled = false }
        }
        let alarm = document.save(settings, id: id, at: now, by: .phone)
        persist()
        do {
            try await sync.apply(alarm)
            problem = problem ?? notice
        } catch {
            settings.isEnabled = false
            let off = document.save(settings, id: id, at: now, by: .phone)
            persist()
            try? await sync.apply(off)
            problem = .couldNotSchedule(settings.time)
        }
    }

    public func setEnabled(_ enabled: Bool, for id: UUID, now: Date = Date()) async {
        guard var settings = document.alarm(id)?.settings else { return }
        settings.isEnabled = enabled
        await save(settings, id: id, now: now)
    }

    public func delete(_ id: UUID, now: Date = Date()) async {
        guard !isReadOnly else { problem = .couldNotLoad; return }
        problem = nil
        document.remove(id, at: now, by: .phone)
        persist()
        try? await sync.remove(id)
    }

    private func persist() {
        do { try file.write(document) } catch { problem = .couldNotSave }
    }
}
