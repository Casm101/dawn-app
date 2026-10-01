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
        let checked = document
        let lost: Set<UUID>
        do {
            lost = try await sync.reconcile(checked)
        } catch {
            problem = .couldNotCheck
            return
        }
        // An alarm changed while the system was being checked, say by the Watch, is not judged on
        // what the check saw.
        let stillLost = lost.filter { document.alarm($0)?.settings == checked.alarm($0)?.settings }
        guard !stillLost.isEmpty else { return }
        for id in stillLost {
            guard var settings = document.alarm(id)?.settings else { continue }
            settings.isEnabled = false
            document.save(settings, id: id, at: now, by: .phone)
        }
        persist()
        onLocalChange?()
    }
}
