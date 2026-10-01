import SwiftUI

/// The rounded surface every Home block sits on.
public struct DawnCard<Content: View>: View {
    private let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: DawnSpacing.sm) {
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(DawnSpacing.lg)
        .background(DawnColor.card, in: RoundedRectangle(cornerRadius: DawnRadius.card, style: .continuous))
    }
}

#Preview {
    DawnCard {
        Text(verbatim: "Last night").font(DawnFont.title)
        Text(verbatim: "Card content").font(DawnFont.body)
    }
    .padding(DawnSpacing.lg)
}
