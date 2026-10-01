import DawnCore
import DawnUI
import SwiftUI

/// The predicted energy as a line down the timeline: further right is more alert.
struct EnergyCurveLine: View {
    let curve: EnergyCurve
    let window: TimelineWindow

    var body: some View {
        Canvas { context, size in
            var path = Path()
            for point in curve.points where window.interval.contains(point.date) {
                let spot = CGPoint(
                    x: EnergyCurve.level(point.alertness) * size.width, y: window.position(point.date) * size.height
                )
                if path.isEmpty { path.move(to: spot) } else { path.addLine(to: spot) }
            }
            context.stroke(path, with: .color(DawnColor.energyLine), style: DawnStroke.energyLine)
        }
        .accessibilityHidden(true)
    }
}
