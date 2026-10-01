import Testing

/// Waits for a condition the engines reach asynchronously, failing after about two seconds.
@MainActor
func eventually(_ condition: () -> Bool) async throws {
    for _ in 0..<200 where !condition() { try await Task.sleep(for: .milliseconds(10)) }
    #expect(condition())
}
