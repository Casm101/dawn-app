extension WakeCoordinator {
    /// Runs `step` once every step before it has finished, so a session event never lands halfway
    /// through arming, and two ends never record one window twice.
    func serially(_ step: @escaping @MainActor () async -> Void) async {
        let previous = queue
        let current = Task { @MainActor in
            await previous?.value
            await step()
        }
        queue = current
        await current.value
    }
}
