@testable import DawnAlarmKit

/// Answers the alarm permission prompt the way the test says.
actor FakeAlarmAuthorizer: AlarmAuthorizing {
    private var current: AlarmPermissionState
    private let answer: AlarmPermissionState
    private(set) var requests = 0

    init(current: AlarmPermissionState = .notDetermined, answer: AlarmPermissionState = .authorized) {
        self.current = current
        self.answer = answer
    }

    func state() async -> AlarmPermissionState { current }

    func request() async -> AlarmPermissionState {
        requests += 1
        current = answer
        return answer
    }
}
