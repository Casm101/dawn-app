import DawnCore
import DawnUI
import SwiftUI

/// Asks how last night was, from 0 to 10, and keeps the answer on that night.
struct RateNightSheet: View {
    let night: CalendarDay
    @Environment(RatingStore.self) private var ratings
    @Environment(\.dismiss) private var dismiss

    private let columns = Array(repeating: GridItem(.flexible(), spacing: DawnSpacing.sm), count: 6)

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: DawnSpacing.lg) {
                Text(String(localized: "rate.question", defaultValue: "How well did you sleep last night?"))
                    .font(DawnFont.title)
                LazyVGrid(columns: columns, spacing: DawnSpacing.sm) {
                    ForEach(Array(NightRating.scale), id: \.self) { score in
                        Button {
                            ratings.rate(night, score)
                            dismiss()
                        } label: {
                            Text(score.formatted()).frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .tint(ratings.ratings.score(for: night) == score ? DawnColor.accent : DawnColor.secondaryText)
                        .font(DawnFont.body.monospacedDigit())
                        .frame(minHeight: DawnSize.tapTarget)
                        .accessibilityIdentifier("rate-\(score)")
                        .accessibilityAddTraits(ratings.ratings.score(for: night) == score ? .isSelected : [])
                    }
                }
                HStack {
                    Text(String(localized: "rate.low", defaultValue: "\(NightRating.scale.lowerBound) is the worst"))
                    Spacer()
                    Text(String(localized: "rate.high", defaultValue: "\(NightRating.scale.upperBound) is the best"))
                }
                .font(DawnFont.caption)
                .foregroundStyle(DawnColor.secondaryText)
                if ratings.isUnsaved {
                    Text(String(localized: "rate.notSaved", defaultValue: "Dawn could not save this rating on this iPhone, so it lasts until Dawn closes."))
                        .font(DawnFont.caption)
                        .foregroundStyle(DawnColor.warning)
                }
                Spacer()
            }
            .padding(DawnSpacing.lg)
            .navigationTitle(HabitText.name(.rateLastNight))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "rate.cancel", defaultValue: "Cancel")) { dismiss() }
                }
            }
        }
        .presentationDetents([.medium])
    }
}
