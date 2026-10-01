import DawnCore
import Foundation

extension AlarmLibrary {
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
        hasLoaded = true
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
        onLocalChange?()
    }
}
