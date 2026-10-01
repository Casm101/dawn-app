import Foundation

/// One card in Home's phase carousel.
public struct PhaseCard: Hashable, Sendable, Identifiable {
    public let span: PhaseSpan
    /// True for the phase under way now, which shows "until" its end.
    public let isCurrent: Bool
    /// Nil when there is no matching phase yesterday.
    public let change: PhaseChange?

    public var id: EnergyPhase { span.phase }

    /// The phase under way first, then the ones still to come in the forecast's day.
    public static func cards(for forecast: EnergyForecast, now: Date, calendar: Calendar) -> [PhaseCard] {
        forecast.today.phases.filter { $0.end > now }.map { span in
            PhaseCard(
                span: span, isCurrent: span.contains(now),
                change: PhaseChange(today: span, yesterday: forecast.yesterday.span(of: span.phase), calendar: calendar)
            )
        }
    }
}
