import SwiftUI

/// A coloured dot, a name and a value, as in a stage breakdown.
public struct LegendItem: View {
    private let name: String
    private let value: String
    private let color: Color

    public init(name: String, value: String, color: Color) {
        self.name = name
        self.value = value
        self.color = color
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: DawnSpacing.xs) {
            HStack(spacing: DawnSpacing.xs) {
                Circle()
                    .fill(color)
                    .frame(width: DawnSpacing.sm, height: DawnSpacing.sm)
                Text(name)
                    .font(DawnFont.caption)
                    .foregroundStyle(DawnColor.secondaryText)
            }
            Text(value)
                .font(DawnFont.body)
                .monospacedDigit()
        }
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    HStack(spacing: DawnSpacing.lg) {
        LegendItem(name: "Awake", value: "16m", color: DawnColor.awake)
        LegendItem(name: "REM", value: "2h 1m", color: DawnColor.rem)
        LegendItem(name: "Core", value: "5h 33m", color: DawnColor.core)
        LegendItem(name: "Deep", value: "41m", color: DawnColor.deep)
    }
    .padding(DawnSpacing.lg)
}
