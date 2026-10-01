import DawnCore
import DawnUI
import SwiftUI

/// The day's phases from the one under way, each with its times and how it moved since yesterday.
struct PhaseCarousel: View {
    let cards: [PhaseCard]
    let isLearning: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: DawnSpacing.sm) {
            HStack {
                Text(String(localized: "home.phases.title", defaultValue: "Your energy today"))
                    .font(DawnFont.title)
                Spacer()
                if isLearning { TagChip(text: PhaseText.learning, color: DawnColor.accent) }
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DawnSpacing.md) {
                    ForEach(cards) { PhaseCardView(card: $0) }
                }
            }
        }
    }
}
