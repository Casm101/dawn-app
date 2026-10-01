import Testing
@testable import DawnSync

struct ReplicaTests {
    @Test func phoneWinsTiesAgainstWatch() {
        #expect(Replica.phone.winsTie(against: .watch))
        #expect(!Replica.watch.winsTie(against: .phone))
    }

    @Test func aReplicaTiesWithItself() {
        #expect(Replica.watch.winsTie(against: .watch))
    }
}
