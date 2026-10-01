import Testing
@testable import DawnHealth

struct FakeHealthAccess: HealthAccess {
    var answer: HealthAccessState

    func state() async -> HealthAccessState { answer }
    func requestSleepRead() async -> HealthAccessState { answer }
}

struct HealthAccessTests {
    @Test func fakeReportsTheConfiguredAnswer() async {
        let access = FakeHealthAccess(answer: .granted)
        #expect(await access.requestSleepRead() == .granted)
    }
}
