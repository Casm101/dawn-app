import SwiftUI

/// The five tabs. Each shows a placeholder until its ticket lands.
struct RootView: View {
    var body: some View {
        TabView {
            Tab("Home", systemImage: "house") { HomeView() }
            Tab("Progress", systemImage: "chart.line.uptrend.xyaxis") { placeholder("Progress") }
            Tab("Energy", systemImage: "list.bullet") { placeholder("Energy") }
            Tab("Tools", systemImage: "briefcase") { placeholder("Tools") }
            Tab("Guidance", systemImage: "bubble") { placeholder("Guidance") }
        }
    }

    private func placeholder(_ title: String) -> some View {
        ContentUnavailableView(title, systemImage: "moon.zzz", description: Text("Coming in a later ticket."))
    }
}

#Preview {
    RootView()
}
