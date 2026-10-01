import DawnCore
import Foundation
import Observation

/// The user's corrections to nights and the naps they added, saved on the phone beside what Health
/// imports. Nothing here is ever written to Health. Edits too old to change are dropped on launch.
@Observable
final class SleepEditsStore {
    private(set) var edits = SleepEdits()
    /// True when the saved edits could not be read; the file is then never written over.
    private(set) var isReadOnly = false
    private(set) var saveFailed = false
    /// True when the last change lives only until Dawn closes.
    var isUnsaved: Bool { isReadOnly || saveFailed }
    private let file: JSONFile<SleepEdits>

    init(file: JSONFile<SleepEdits>) {
        self.file = file
        do {
            edits = (try file.read() ?? SleepEdits()).pruned(now: Date(), calendar: .current)
        } catch {
            isReadOnly = true
        }
    }

    func save(_ correction: NightCorrection) {
        edits.save(correction)
        persist()
    }

    func reset(_ day: CalendarDay) {
        edits.reset(day)
        persist()
    }

    func add(_ nap: ManualNap, existing: [SleepSession], now: Date = Date()) -> NightEditProblem? {
        if let problem = edits.add(nap, existing: existing, now: now, calendar: .current) { return problem }
        persist()
        return nil
    }

    func removeNap(_ id: UUID) {
        edits.removeNap(id)
        persist()
    }

    private func persist() {
        guard !isReadOnly else { return }
        do {
            try file.write(edits)
            saveFailed = false
        } catch {
            saveFailed = true
        }
    }
}
