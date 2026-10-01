import DawnCore
import Observation

/// Where a tapped reminder takes the user: the rating prompt opens Energy with the rating sheet.
@MainActor
@Observable
final class HabitRouter {
    var tab = RootTab.home
    var isRating = false

    func open(_ habit: Habit) {
        tab = .energy
        if habit == .rateLastNight { isRating = true }
    }
}
