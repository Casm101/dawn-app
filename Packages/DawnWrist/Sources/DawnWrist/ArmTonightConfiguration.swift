import AppIntents

/// The Smart Stack widget's configuration. There is nothing to choose; it exists so the Watch app
/// can tell the system when the "Arm tonight" widget is worth showing.
public struct ArmTonightConfiguration: WidgetConfigurationIntent {
    public static let title: LocalizedStringResource = "Arm tonight"

    public init() {}
}
