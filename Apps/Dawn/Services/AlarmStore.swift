import DawnAlarmKit
import DawnCore
import Foundation
import Observation

/// The user's alarms, saved on the phone and kept in step with the system's alarms.
@Observable
final class AlarmStore {
    private(set) var document = AlarmDocument()
    private(set) var permission: AlarmPermissionState = .notDetermined
    /// Set when the last save hit a problem the user should see.
    private(set) var problem: AlarmProblem?

    private let file: JSONFile<AlarmDocument>
    private let sync: AlarmSystemSync
    private let authorizer: any AlarmAuthorizing

    init(file: JSONFile<AlarmDocument>, sync: AlarmSystemSync, authorizer: any AlarmAuthorizing) {
        self.file = file
        self.sync = sync
        self.authorizer = authorizer
    }

    var alarms: [AlarmDefinition] { document.alarms }

    /// The soonest ring among the enabled alarms.
    var nextRing: Date? {
        alarms.filter(\.isEnabled)
            .compactMap { AlarmOccurrence.next($0, after: Date(), calendar: .current) }
            .min()
    }

    /// Loads the saved alarms and switches off any the system no longer has.
    func load() async {
        document = (try? file.read()) ?? AlarmDocument()
        permission = await authorizer.state()
        guard let lost = try? await sync.reconcile(document), !lost.isEmpty else { return }
        for id in lost {
            guard var alarm = document.alarm(id) else { continue }
            alarm.isEnabled = false
            document.upsert(alarm, at: Date())
        }
        persist()
    }

    func save(_ alarm: AlarmDefinition) async {
        problem = nil
        if alarm.isEnabled, permission != .authorized {
            permission = await authorizer.request()
        }
        var alarm = alarm
        if permission != .authorized { alarm.isEnabled = false }
        document.upsert(alarm, at: Date())
        persist()
        do {
            try await sync.apply(alarm)
        } catch {
            problem = .couldNotSchedule
        }
    }

    func setEnabled(_ enabled: Bool, for id: UUID) async {
        guard var alarm = document.alarm(id) else { return }
        alarm.isEnabled = enabled
        await save(alarm)
    }

    func delete(_ id: UUID) async {
        document.remove(id, at: Date())
        persist()
        try? await sync.remove(id)
    }

    private func persist() {
        try? file.write(document)
    }
}
