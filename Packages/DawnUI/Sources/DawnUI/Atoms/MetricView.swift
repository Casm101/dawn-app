import SwiftUI

/// A screen's headline number with its caption underneath.
public struct MetricView: View {
    private let value: String
    private let caption: String

    public init(value: String, caption: String) {
        self.value = value
        self.caption = caption
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: DawnSpacing.xs) {
            Text(value)
                .font(DawnFont.metric)
                .monospacedDigit()
            Text(caption)
                .font(DawnFont.caption)
                .foregroundStyle(DawnColor.secondaryText)
        }
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    MetricView(value: "6h 22m", caption: "Asleep")
        .padding(DawnSpacing.lg)
}
