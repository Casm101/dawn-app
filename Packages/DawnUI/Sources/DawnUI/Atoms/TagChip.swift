import SwiftUI

/// A short label on a tinted capsule, such as a debt band.
public struct TagChip: View {
    private let text: String
    private let color: Color

    public init(text: String, color: Color) {
        self.text = text
        self.color = color
    }

    public var body: some View {
        Text(text)
            .font(DawnFont.caption.weight(.semibold))
            .foregroundStyle(color)
            .padding(.horizontal, DawnSpacing.sm)
            .padding(.vertical, DawnSpacing.xs)
            .background(color.opacity(0.18), in: Capsule())
    }
}

#Preview {
    TagChip(text: "Building", color: DawnColor.bandBuilding)
        .padding(DawnSpacing.lg)
}
