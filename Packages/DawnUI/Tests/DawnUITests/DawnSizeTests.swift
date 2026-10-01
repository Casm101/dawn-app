import Testing
@testable import DawnUI

struct DawnSizeTests {
    @Test func tapTargetsMeetTheFortyFourPointMinimum() {
        #expect(DawnSize.tapTarget >= 44)
        #expect(DawnSize.chip <= DawnSize.tapTarget)
    }
}
