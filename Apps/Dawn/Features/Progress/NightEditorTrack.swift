import DawnCore
import DawnUI
import SwiftUI

/// The night's stretches of sleep on a track. Dragging either end moves it in five-minute steps
/// with the new length shown as it moves; pressing and holding a stretch inserts an awake gap there.
/// A change that would leave a stretch too short snaps back and is reported.
struct NightEditorTrack: View {
    let edit: NightEdit
    let commit: (NightEdit) -> Void
    let refuse: (NightEditProblem) -> Void
    @State private var preview: NightEdit?
    @State private var moving: Int?
    @State private var span: DateInterval?
    /// A finger held still on a stretch: where it went down, and the wait before it counts as a press.
    @State private var hold: Task<Void, Never>?

    var body: some View {
        let shown = preview ?? edit
        VStack(alignment: .leading, spacing: DawnSpacing.sm) {
            Text(EditText.total(shown)).font(DawnFont.title).monospacedDigit()
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule().fill(DawnColor.card).frame(height: DawnSize.editBar)
                    ForEach(Array(shown.segments.enumerated()), id: \.offset) { index, segment in
                        bar(index, segment, width: geometry.size.width)
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
        .onAppear { span = span ?? edit.track }
    }

    private static let space = "night-track"

    private func bar(_ index: Int, _ segment: DateInterval, width: CGFloat) -> some View {
        let from = x(segment.start, width), to = x(segment.end, width)
        return RoundedRectangle(cornerRadius: DawnRadius.chip)
            .fill(DawnColor.accent)
            .frame(width: max(DawnSize.minimumBar, to - from), height: DawnSize.editBar)
            .offset(x: from)
            .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .named(Self.space))
                .onChanged { value in
                    let moved = abs(value.translation.width) + abs(value.translation.height)
                    if moved > DawnSize.pressSlop {
                        hold?.cancel()
                    } else if hold == nil {
                        let at = date(value.startLocation.x, width)
                        hold = Task { @MainActor in
                            try? await Task.sleep(for: .seconds(Tuning.Edits.pressDuration))
                            guard !Task.isCancelled else { return }
                            apply { $0.insertGap(at: at) }
                        }
                    }
                }
                .onEnded { _ in
                    hold?.cancel()
                    hold = nil
                })
            .accessibilityElement()
            .accessibilityLabel(EditText.stretch(segment))
            .accessibilityAction(named: Text(EditText.insertGap)) {
                apply { $0.insertGap(at: segment.start.addingTimeInterval(segment.duration / 2)) }
            }
    }

    private func handle(_ index: Int, _ edge: NightEdge, at moment: Date, width: CGFloat) -> some View {
        Circle()
            .fill(DawnColor.onAccent)
            .overlay(Circle().stroke(DawnColor.accent, lineWidth: DawnSize.nowLine))
            .frame(width: DawnSize.editHandle, height: DawnSize.editHandle)
            .offset(x: x(moment, width) - DawnSize.editHandle / 2)
            .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .named(Self.space))
                .onChanged { value in
                    moving = index
                    var draft = edit
                    if draft.move(index, edge, to: date(value.location.x, width)) == nil { preview = draft }
                }
                .onEnded { value in
                    preview = nil
                    moving = nil
                    apply { $0.move(index, edge, to: date(value.location.x, width)) }
                })
            .accessibilityIdentifier("night-handle-\(index)-\(edge == .start ? "start" : "end")")
            .accessibilityLabel(EditText.handle(edge, at: moment))
            .accessibilityAdjustableAction { direction in
                let step = direction == .increment ? Tuning.Edits.step : -Tuning.Edits.step
                apply { $0.move(index, edge, to: moment.addingTimeInterval(step)) }
            }
    }

    /// Applies one change to the saved night: commits it, or reports why it was refused.
    private func apply(_ change: (inout NightEdit) -> NightEditProblem?) {
        var draft = edit
        if let problem = change(&draft) { refuse(problem) } else { commit(draft) }
    }

    private func x(_ moment: Date, _ width: CGFloat) -> CGFloat {
        guard let span, span.duration > 0 else { return 0 }
        return CGFloat(moment.timeIntervalSince(span.start) / span.duration) * width
    }

    private func date(_ x: CGFloat, _ width: CGFloat) -> Date {
        guard let span, width > 0 else { return edit.segments.first?.start ?? Date() }
        return span.start.addingTimeInterval(Double(min(max(x, 0), width) / width) * span.duration)
    }
}
