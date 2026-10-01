import DawnCore
import SwiftUI
import Testing
@testable import DawnUI

struct DawnColorTests {
    @Test func everyStageHasItsOwnColour() {
        let colours = SleepStage.allCases.map(DawnColor.stage)
        #expect(Set(colours).count == SleepStage.allCases.count)
    }
}
