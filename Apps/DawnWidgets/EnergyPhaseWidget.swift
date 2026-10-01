import SwiftUI
import WidgetKit

/// Placeholder until the schedule exists: shows the app name and the time.
struct EnergyPhaseWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "EnergyPhase", provider: EnergyPhaseProvider()) { entry in
            VStack(alignment: .leading) {
                Text("Dawn").font(.headline)
                Text(entry.date, style: .time).font(.caption)
            }
            .containerBackground(.background, for: .widget)
        }
        .configurationDisplayName("Energy phase")
        .description("Your current energy phase and when it ends.")
    }
}

struct EnergyPhaseEntry: TimelineEntry {
    let date: Date
}

struct EnergyPhaseProvider: TimelineProvider {
    func placeholder(in context: Context) -> EnergyPhaseEntry { EnergyPhaseEntry(date: .now) }
    func getSnapshot(in context: Context, completion: @escaping (EnergyPhaseEntry) -> Void) {
        completion(EnergyPhaseEntry(date: .now))
    }
    func getTimeline(in context: Context, completion: @escaping (Timeline<EnergyPhaseEntry>) -> Void) {
        completion(Timeline(entries: [EnergyPhaseEntry(date: .now)], policy: .atEnd))
    }
}
