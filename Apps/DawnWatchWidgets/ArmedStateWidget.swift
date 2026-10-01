import SwiftUI
import WidgetKit

/// Placeholder complication: an alarm glyph until the armed state syncs.
struct ArmedStateWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "ArmedState", provider: ArmedStateProvider()) { _ in
            Image(systemName: "alarm")
                .containerBackground(.background, for: .widget)
        }
        .configurationDisplayName("Wake window")
        .description("Whether tonight's wake window is armed.")
        .supportedFamilies([.accessoryCircular, .accessoryRectangular, .accessoryInline])
    }
}

struct ArmedStateEntry: TimelineEntry {
    let date: Date
}

struct ArmedStateProvider: TimelineProvider {
    func placeholder(in context: Context) -> ArmedStateEntry { ArmedStateEntry(date: .now) }
    func getSnapshot(in context: Context, completion: @escaping (ArmedStateEntry) -> Void) {
        completion(ArmedStateEntry(date: .now))
    }
    func getTimeline(in context: Context, completion: @escaping (Timeline<ArmedStateEntry>) -> Void) {
        completion(Timeline(entries: [ArmedStateEntry(date: .now)], policy: .atEnd))
    }
}
