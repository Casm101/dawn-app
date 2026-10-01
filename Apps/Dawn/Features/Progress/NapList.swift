import DawnCore
import DawnUI
import SwiftUI

/// The naps within `Tuning.Edits.days`, newest first, from Health and added by hand; added ones can be deleted.
struct NapList: View {
    @Environment(SleepEditsStore.self) private var edits
    let sessions: [SleepSession]
    @State private var adding = false

    var body: some View {
        VStack(alignment: .leading, spacing: DawnSpacing.sm) {
            HStack {
                Text(String(localized: "progress.naps.title", defaultValue: "Naps")).font(DawnFont.title)
                Spacer()
                Button(String(localized: "progress.naps.add", defaultValue: "Add nap"), systemImage: "plus") { adding = true }
            }
            if naps.isEmpty {
                Text(String(localized: "progress.naps.empty", defaultValue: "No naps in the last \(Tuning.Edits.days) days."))
                    .font(DawnFont.body)
                    .foregroundStyle(DawnColor.secondaryText)
            }
            if edits.isUnsaved {
                Text(EditText.notSaved).font(DawnFont.caption).foregroundStyle(DawnColor.warning)
            }
            ForEach(naps) { nap in
                DawnCard {
                    HStack {
                        VStack(alignment: .leading, spacing: DawnSpacing.xs) {
                            Text(nap.start.formatted(.dateTime.weekday(.wide).day().month())).font(DawnFont.body.weight(.semibold))
                            Text(NightText.range(nap.start, nap.end)).font(DawnFont.caption).foregroundStyle(DawnColor.secondaryText)
                        }
                        Spacer()
                        Text(DurationFormat.short(nap.span)).font(DawnFont.body).monospacedDigit()
                        if let added = added(nap) {
                            Button(EditText.delete, systemImage: "trash", role: .destructive) { edits.removeNap(added.id) }
                                .labelStyle(.iconOnly)
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $adding) { AddNapView() }
    }

    private var naps: [SleepSession] {
        sessions.filter { $0.kind == .nap && SleepEdits.isEditable(day: Calendar.current.startOfDay(for: $0.start), now: Date(), calendar: .current) }
            .sorted { $0.start > $1.start }
    }

    private func added(_ nap: SleepSession) -> ManualNap? {
        edits.edits.naps.first { $0.start == nap.start && $0.end == nap.end }
    }
}
