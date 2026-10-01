import Foundation

extension Tuning {
    /// Alarm defaults and the system's scheduling limits.
    public enum Alarm {
        /// A freshly scheduled alarm closer than this to its fire time may not ring.
        public static let minimumLeadTime: TimeInterval = 90
        public static let defaultSnoozeMinutes = 9
        public static let snoozeMinutes: ClosedRange<Int> = 1...30
        /// The wake window on the Watch ends at the alarm time.
        public static let defaultWindowMinutes = 30
        public static let windowMinutes: ClosedRange<Int> = 10...30
    }
}
