import DawnCore
import DawnUI
import SwiftUI

/// The usual bedtime and wake time, which the energy schedule uses until Health has enough nights.
struct UsualSleepSection: View {
    @Environment(UsualSleepStore.self) private var store

    var body: some View {
        Section {
            DatePicker(
                String(localized: "profile.usual.bed", defaultValue: "Usual bedtime"),
                selection: time(\.bedtime), displayedComponents: .hourAndMinute
            )
            DatePicker(
                String(localized: "profile.usual.wake", defaultValue: "Usual wake time"),
                selection: time(\.wakeTime), displayedComponents: .hourAndMinute
            )
        } footer: {
            VStack(alignment: .leading, spacing: DawnSpacing.sm) {
                Text(String(
                    localized: "profile.usual.footer",
                    defaultValue: "Your energy schedule starts from these until Dawn has \(Tuning.Energy.minimumNights) nights of sleep from Health in the last week."
                ))
                if store.isReadOnly || store.saveFailed {
                    Text(String(
                        localized: "profile.usual.notSaved",
                        defaultValue: "Dawn could not save these times on this iPhone, so changes last until Dawn closes."
                    ))
                    .foregroundStyle(DawnColor.warning)
                }
            }
        }
    }

    private func time(_ field: WritableKeyPath<UsualSleep, ClockTime>) -> Binding<Date> {
        Binding(
            get: { store.usual[keyPath: field].date(on: Date(), calendar: .current) },
            set: { date in
                var usual = store.usual
                usual[keyPath: field] = ClockTime(date, calendar: .current)
                store.set(usual)
            }
        )
    }
}
