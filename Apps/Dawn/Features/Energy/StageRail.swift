import DawnCore
import DawnUI
import SwiftUI

/// The night's stages minute by minute, as a hypnogram on its side: awake to the left, deep to the
/// right, each in its stage colour.
struct StageRail: View {
    let runs: [StageRun]
    let window: TimelineWindow

    var body: some View {
        Canvas { context, size in
            let laneWidth = size.width / CGFloat(StageLane.count)
            for run in runs {
                let top = window.position(run.start) * size.height
                let bottom = window.position(run.end) * size.height
                let rect = CGRect(
                    x: CGFloat(StageLane.lane(run.stage)) * laneWidth, y: top,
                    width: laneWidth, height: max(DawnSize.hairline, bottom - top)
                )
                context.fill(Path(rect), with: .color(DawnColor.stage(run.stage)))
            }
        }
        .accessibilityLabel(String(localized: "energy.rail", defaultValue: "Sleep stages"))
    }
}
