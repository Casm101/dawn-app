/// Something that went wrong while saving an alarm, worth telling the user about.
enum AlarmProblem: Equatable {
    /// The system refused the alarm, so it will not ring.
    case couldNotSchedule
}
