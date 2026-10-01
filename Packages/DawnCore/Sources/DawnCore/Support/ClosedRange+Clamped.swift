extension ClosedRange {
    /// The value, moved inside the range when it falls outside.
    func clamped(_ value: Bound) -> Bound { Swift.min(Swift.max(value, lowerBound), upperBound) }
}
