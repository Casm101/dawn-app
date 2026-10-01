import SwiftUI

/// The Watch's single screen until the wake window lands: what is, or is not, armed tonight.
struct TonightView: View {
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "moon.zzz")
                .font(.largeTitle)
            Text("Nothing to arm")
                .font(.headline)
            Text("Set an alarm on your iPhone.")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    TonightView()
}
