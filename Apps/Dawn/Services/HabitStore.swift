import DawnCore
import Foundation
import Observation

/// Which habits show on the timeline and which remind, saved on the phone.
@Observable
final class HabitStore {
    private(set) var settings = HabitSettings()
    /// True when the saved settings could not be read; the file is then never written over.
    private(set) var isReadOnly = false
    private(set) var saveFailed = false
    var isUnsaved: Bool { isReadOnly || saveFailed }
    private let file: JSONFile<HabitSettings>

    init(file: JSONFile<HabitSettings>) {
        self.file = file
        do {
            settings = try file.read() ?? HabitSettings()
        } catch {
            isReadOnly = true
        }
    }

    func show(_ habit: Habit, _ on: Bool) {
        settings.show(habit, on)
        persist()
    }

    func remind(_ habit: Habit, _ on: Bool) {
        settings.remind(habit, on)
        persist()
    }

    private func persist() {
        guard !isReadOnly else { return }
        do {
            try file.write(settings)
            saveFailed = false
        } catch {
            saveFailed = true
        }
    }
}
