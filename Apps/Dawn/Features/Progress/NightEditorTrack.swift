import DawnCore
import DawnUI
import SwiftUI

/// The night's stretches of sleep on a track. Dragging either end moves it in `Tuning.Edits.step`
/// steps with the new length shown as it moves; pressing and holding a stretch inserts an awake gap
/// there (see `NightStretchBar`). A change that would leave a stretch too short snaps back and is reported.
struct NightEditorTrack: View {
    let edit: NightEdit
    let commit: (NightEdit) -> Void
    let refuse: (NightEditProblem) -> Void
    /// The night as an end is being dragged, and which stretch it belongs to. Both clear when the
    /// finger lifts or the drag is cancelled.
    @GestureState private var preview: NightEdit?
    @GestureState private var moving: Int?
    @State private var scale: TrackScale?

    var body: some View {
        let shown = preview ?? edit
        VStack(alignment: .leading, spacing: DawnSpacing.sm) {
            Text(EditText.total(shown)).font(DawnFont.title).monospacedDigit()
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule().fill(DawnColor.card).frame(height: DawnSize.editBar)
                    if let scale {
                        ForEach(Array(shown.segments.enumerated()), id: \.offset) { _, segment in
                            NightStretchBar(segment: segment, scale: scale, width: geometry.size.width, space: Self.space) { moment in
                                apply { $0.insertGap(at: moment) }
                            }
                        }
                    }
                    ForEach(Array(shown.segments.enumerated()), id: \.offset) { index, segment in
                        handle(index, .start, at: segment.start, width: geometry.size.width)
                        handle(index, .end, at: segment.end, width: geometry.size.width)
                    }
                }
                .coordinateSpace(.named(Self.space))
            }
            .frame(height: DawnSize.editHandle)
            if let moving, shown.segments.indices.contains(moving) {
                Text(EditText.stretch(shown.segments[moving])).font(DawnFont.caption).monospacedDigit()
            }
        }
        .onAppear { widen() }
        .onChange(of: edit) { widen() }
    }

    private static let space = "night-track"

    private func handle(_ index: Int, _ edge: NightEdge, at moment: Date, width: CGFloat) -> some View {
        Circle()
            .fill(DawnColor.onAccent)
            .overlay(Circle().stroke(DawnColor.accent, lineWidth: DawnSize.editHandleStroke))
            .frame(width: DawnSize.editHandle, height: DawnSize.editHandle)
            .offset(x: x(moment, width) - DawnSize.editHandle / 2)
            .gesture(DragGesture(minimumDistance: 0)
                .updating($moving) { value, state, _ in
                    if abs(value.translation.width) > DawnSize.pressSlop { state = index }
                }
                .updating($preview) { value, state, _ in
                    guard abs(value.translation.width) > DawnSize.pressSlop else { return }
                    var draft = edit
                    if draft.move(index, edge, to: dragged(index, edge, by: value.translation.width, width)) == nil { state = draft }
                }
                .onEnded { value in
                    guard abs(value.translation.width) > DawnSize.pressSlop else { return }
                    apply { $0.move(index, edge, to: dragged(index, edge, by: value.translation.width, width)) }
                })
            .accessibilityIdentifier("night-handle-\(index)-\(edge == .start ? "start" : "end")")
            .accessibilityLabel(EditText.handle(edge, at: moment))
            .accessibilityAdjustableAction { direction in
                let step = direction == .increment ? Tuning.Edits.step : -Tuning.Edits.step
                apply { $0.move(index, edge, to: moment.addingTimeInterval(step)) }
            }
    }

    /// Where an end lands after being dragged `distance` from where the saved night has it.
    private func dragged(_ index: Int, _ edge: NightEdge, by distance: CGFloat, _ width: CGFloat) -> Date {
        guard edit.segments.indices.contains(index) else { return Date() }
        let segment = edit.segments[index]
        return date(x(edge == .start ? segment.start : segment.end, width) + distance, width)
    }

    /// Applies one change to the saved night: commits it if it changed anything, or reports why it was refused.
    private func apply(_ change: (inout NightEdit) -> NightEditProblem?) {
        var draft = edit
        if let problem = change(&draft) { refuse(problem) } else if draft != edit { commit(draft) }
    }

    /// Grows the track when the night has moved past it.
    private func widen() {
        guard let track = edit.track else { return }
        if scale == nil { scale = TrackScale(span: track) } else { scale?.widen(to: track) }
    }

    private func x(_ moment: Date, _ width: CGFloat) -> CGFloat {
        CGFloat(scale?.x(moment, width: width) ?? 0)
    }

    private func date(_ x: CGFloat, _ width: CGFloat) -> Date {
        scale?.date(x, width: width) ?? edit.segments.first?.start ?? Date()
    }
}
