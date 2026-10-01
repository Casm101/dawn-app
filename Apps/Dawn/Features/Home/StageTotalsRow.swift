import DawnCore
import DawnUI
import SwiftUI

/// Awake, REM, core and deep side by side, each in its stage colour.
struct StageTotalsRow: View {
    let totals: StageTotals

    var body: some View {
        HStack(alignment: .top, spacing: DawnSpacing.lg) {
            item(String(localized: "stage.awake", defaultValue: "Awake"), totals.awake, .awake)
            item(String(localized: "stage.rem", defaultValue: "REM"), totals.rem, .rem)
            item(String(localized: "stage.core", defaultValue: "Core"), totals.core, .core)
            item(String(localized: "stage.deep", defaultValue: "Deep"), totals.deep, .deep)
            if totals.unspecified > 0 {
                item(String(localized: "stage.unspecified", defaultValue: "No stage"), totals.unspecified, .unspecified)
            }
        }
    }

    private func item(_ name: String, _ value: TimeInterval, _ stage: SleepStage) -> some View {
        LegendItem(name: name, value: DurationFormat.short(value), color: DawnColor.stage(stage))
    }
}
