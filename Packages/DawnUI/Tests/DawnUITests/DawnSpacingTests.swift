import Testing
@testable import DawnUI

struct DawnSpacingTests {
    @Test func scaleIsStrictlyIncreasing() {
        let scale = [DawnSpacing.xs, DawnSpacing.sm, DawnSpacing.md, DawnSpacing.lg, DawnSpacing.xl, DawnSpacing.xxl]
        #expect(scale == scale.sorted())
        #expect(Set(scale).count == scale.count)
    }
}
