/// The bundled gentle-wake sounds. Each file starts quiet and reaches full volume within the clip.
public enum AlarmSound: String, Codable, Sendable, CaseIterable {
    case chimes
    case sunrise
    case pulse

    /// The file name in the app bundle, as AlarmKit and the preview player look it up.
    public var fileName: String { "dawn-\(rawValue).caf" }
}
