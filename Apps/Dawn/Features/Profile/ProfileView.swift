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
                    Stepper(value: needValue, in: Tuning.Need.range, step: Tuning.Need.manualStep) {
                        LabeledContent(
                            String(localized: "profile.need", defaultValue: "Sleep need"),
                            value: DurationFormat.short(needs.need.value)
                        )
                    }
                    Toggle(String(localized: "profile.learn", defaultValue: "Learn from my sleep"), isOn: learning)
                } footer: {
                    VStack(alignment: .leading, spacing: DawnSpacing.sm) {
                        Text(footer)
                        if needs.isReadOnly || needs.saveFailed {
                            Text(String(
                                localized: "profile.need.notSaved",
                                defaultValue: "Dawn could not save your sleep need on this iPhone, so changes last until Dawn closes."
                            ))
                            .foregroundStyle(DawnColor.warning)
                        }
                    }
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
        // A learned value can sit between steps; a value set by hand lands on the rounding grid.
        Binding(get: { needs.need.value }, set: { value in
            let grid = Tuning.Need.manualRounding
            needs.set((value / grid).rounded() * grid)
        })
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
