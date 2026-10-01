import SwiftUI

/// The five tabs. Each shows a placeholder until its ticket lands. Health is followed here, not in
/// a tab, so every tab sees new sleep whichever one is showing.
struct RootView: View {
    @Environment(SleepStore.self) private var sleep
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        TabView {
            Tab("Home", systemImage: "house") { HomeView() }
            Tab("Progress", systemImage: "chart.line.uptrend.xyaxis") { SleepProgressView() }
            Tab("Energy", systemImage: "list.bullet") { EnergyView() }
            Tab("Tools", systemImage: "briefcase") { placeholder("Tools") }
            Tab("Guidance", systemImage: "bubble") { placeholder("Guidance") }
        }
        .task { await sleep.refreshAccess() }
        .task(id: sleep.access) { await sleep.follow() }
        .onChange(of: scenePhase) { _, phase in
            guard phase == .active else { return }
            Task { await sleep.reload() }
        }
    }

    private func placeholder(_ title: String) -> some View {
        ContentUnavailableView(title, systemImage: "moon.zzz", description: Text("Coming in a later ticket."))
    }
}

#Preview {
    RootView()
}
