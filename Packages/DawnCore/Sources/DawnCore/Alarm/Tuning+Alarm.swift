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
        /// The wake zone runs this long either side of the habitual wake.
        public static let wakeZoneHalfWidth: TimeInterval = 30 * 60
        /// Dragging the alarm on the editor's track moves it in steps of this.
        public static let dragStep: TimeInterval = 5 * 60
        /// The editor's track shows this much before bedtime and after the wake zone or the alarm.
        public static let trackMargin: TimeInterval = 3600
    }
}
