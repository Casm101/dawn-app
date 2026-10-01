import SwiftUI

/// A round on/off chip holding one short label, such as a weekday initial.
public struct DayChip: View {
    private let label: String
    private let isOn: Bool
    private let toggle: () -> Void

    public init(label: String, isOn: Bool, toggle: @escaping () -> Void) {
        self.label = label
        self.isOn = isOn
        self.toggle = toggle
    }

    public var body: some View {
        Button(action: toggle) {
            Text(label)
                .font(DawnFont.body.weight(.semibold))
                .frame(width: DawnSize.chip, height: DawnSize.chip)
                .foregroundStyle(isOn ? DawnColor.onAccent : DawnColor.secondaryText)
                .background(isOn ? DawnColor.accent : DawnColor.card, in: Circle())
                .frame(width: DawnSize.tapTarget, height: DawnSize.tapTarget)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isOn ? .isSelected : [])
    }
}

#Preview {
    HStack(spacing: DawnSpacing.sm) {
        DayChip(label: "M", isOn: true) {}
        DayChip(label: "T", isOn: false) {}
    }
    .padding(DawnSpacing.lg)
}
