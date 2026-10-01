import Testing
@testable import DawnWrist

struct WristSessionStateTests {
    @Test func onlyIdleAndEndedCanArm() {
        #expect(WristSessionState.idle.canArm)
        #expect(WristSessionState.ended.canArm)
        #expect(!WristSessionState.scheduled.canArm)
        #expect(!WristSessionState.running.canArm)
        #expect(!WristSessionState.alerting.canArm)
    }
}
