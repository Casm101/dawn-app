/// Which of the three bands a debt falls in.
public enum DebtBand: Sendable, CaseIterable {
    case okay
    case building
    case high

    public init(hours: Double) {
        if hours < Tuning.Debt.okayBelow {
            self = .okay
        } else if hours > Tuning.Debt.highAbove {
            self = .high
        } else {
            self = .building
        }
    }
}
