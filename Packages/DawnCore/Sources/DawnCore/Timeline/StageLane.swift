/// Where each stage sits across the stage rail, from awake on the left to deep on the right, as on
/// a hypnogram turned on its side.
public enum StageLane {
    public static let count = 4

    public static func lane(_ stage: SleepStage) -> Int {
        switch stage {
        case .awake: 0
        case .rem: 1
        case .core, .unspecified: 2
        case .deep: 3
        }
    }
}
