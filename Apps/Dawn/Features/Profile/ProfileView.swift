import DawnCore
import DawnUI
import SwiftUI

/// Sleep need: set by hand, or left to learn from nights no alarm ended.
struct ProfileView: View {
    @Environment(NeedStore.self) private var needs
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Stepper(value: needValue, in: Tuning.Need.range, step: 15 * 60) {
                        LabeledContent(
                            String(localized: "profile.need", defaultValue: "Sleep need"),
                            value: DurationFormat.short(needs.need.value)
                        )
                    }
                    Toggle(String(localized: "profile.learn", defaultValue: "Learn from my sleep"), isOn: learning)
                } footer: {
                    Text(footer)
                }
            }
            .navigationTitle(String(localized: "profile.title", defaultValue: "Profile"))
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "profile.done", defaultValue: "Done")) { dismiss() }
                }
            }
        }
    }

    private var needValue: Binding<TimeInterval> {
        // A learned value can sit between steps; a value set by hand lands on whole five minutes.
        Binding(get: { needs.need.value }, set: { needs.set(($0 / 300).rounded() * 300) })
    }

    private var learning: Binding<Bool> {
        Binding(get: { !needs.need.isManual }, set: { on in
            if on { needs.resumeLearning() } else { needs.set(needs.need.value) }
        })
    }

    private var footer: String {
        let weekly = DurationFormat.short(Tuning.Need.maxWeeklyChange)
        return String(
            localized: "profile.need.footer",
            defaultValue: "Sleep debt is measured against this. While learning, Dawn moves it by at most \(weekly) a week, using only nights no alarm ended. Changing it by hand stops the learning."
        )
    }
}
