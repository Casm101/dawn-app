import SwiftUI

/// A habit on the timeline: its symbol and name on a capsule, faded once its time has passed.
public struct TimelineChip: View {
    private let symbol: String
    private let text: String
    private let isPast: Bool

    public init(symbol: String, text: String, isPast: Bool) {
        self.symbol = symbol
        self.text = text
        self.isPast = isPast
    }

    public var body: some View {
        Label(text, systemImage: symbol)
            .font(DawnFont.caption.weight(.semibold))
            .lineLimit(1)
            .foregroundStyle(DawnColor.habit)
            .padding(.horizontal, DawnSpacing.sm)
            .padding(.vertical, DawnSpacing.xs)
            .background(DawnColor.habitBackground, in: Capsule())
            .opacity(isPast ? DawnColor.pastOpacity : 1)
    }
}

#Preview {
    VStack(alignment: .leading, spacing: DawnSpacing.sm) {
        TimelineChip(symbol: "sun.max", text: "Morning light", isPast: true)
        TimelineChip(symbol: "moon", text: "Wind down", isPast: false)
    }
    .padding(DawnSpacing.lg)
}
