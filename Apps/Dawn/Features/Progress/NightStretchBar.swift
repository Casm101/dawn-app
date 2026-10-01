import DawnCore
import DawnUI
import SwiftUI

/// One stretch of sleep on the night editor's track. Holding a finger still on it for
/// `Tuning.Edits.pressDuration` asks for an awake gap where the finger went down.
struct NightStretchBar: View {
    let segment: DateInterval
    let scale: TrackScale
    let width: CGFloat
    /// The name of the track's coordinate space, which `scale` measures across.
    let space: String
    let insertGap: (Date) -> Void
    /// The moment under a finger held still here; clears when it lifts, moves or is cancelled.
    @GestureState private var pressed: Date?
    @State private var hold: Task<Void, Never>?

    var body: some View {
        let from = CGFloat(scale.x(segment.start, width: width)), to = CGFloat(scale.x(segment.end, width: width))
        RoundedRectangle(cornerRadius: DawnRadius.chip)
            .fill(DawnColor.accent)
            .frame(width: max(DawnSize.minimumBar, to - from), height: DawnSize.editBar)
            .offset(x: from)
            .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .named(space))
                .updating($pressed) { value, state, _ in
                    let moved = abs(value.translation.width) + abs(value.translation.height)
                    state = moved > DawnSize.pressSlop ? nil : state ?? scale.date(value.startLocation.x, width: width)
                })
            .onChange(of: pressed) { _, moment in
                hold?.cancel()
                guard let moment else { return }
                hold = Task { @MainActor in
                    try? await Task.sleep(for: .seconds(Tuning.Edits.pressDuration))
                    guard !Task.isCancelled else { return }
                    insertGap(moment)
                }
            }
            .onDisappear { hold?.cancel() }
            .accessibilityElement()
            .accessibilityLabel(EditText.stretch(segment))
            .accessibilityAction(named: Text(EditText.insertGap)) {
                insertGap(segment.start.addingTimeInterval(segment.duration / 2))
            }
    }
}
