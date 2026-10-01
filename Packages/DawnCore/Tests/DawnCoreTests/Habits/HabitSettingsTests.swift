import Foundation
import Testing
@testable import DawnCore

/// Which habits show and remind.
struct HabitSettingsTests {
    @Test func everyHabitShowsByDefaultExceptTheSupplementAndNoneReminds() {
        let settings = HabitSettings()
        #expect(Habit.allCases.filter(settings.isShown) == [.morningLight, .caffeineCutoff, .dimLights, .windDown, .rateLastNight])
        #expect(Habit.allCases.filter(settings.reminds).isEmpty)
    }

    @Test func turningAHabitOffTurnsItsReminderOff() {
        var settings = HabitSettings()
        settings.remind(.windDown, true)
        settings.show(.windDown, false)
        settings.show(.windDown, true)
        #expect(!settings.reminds(.windDown))
    }

    @Test func aHiddenHabitCannotRemind() {
        var settings = HabitSettings()
        settings.remind(.melatonin, true)
        #expect(!settings.reminds(.melatonin))
        settings.show(.melatonin, true)
        settings.remind(.melatonin, true)
        #expect(settings.reminds(.melatonin))
    }

    @Test func settingsSurviveBeingSavedAndReadBack() throws {
        var settings = HabitSettings()
        settings.show(.melatonin, true)
        settings.remind(.caffeineCutoff, true)
        let file = JSONFile<HabitSettings>(url: FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID()).json"))
        try file.write(settings)
        #expect(try file.read() == settings)
    }
}
