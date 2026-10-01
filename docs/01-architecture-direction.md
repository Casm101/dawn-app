# Dawn — architecture direction

Date: 2026-09-30. Builds on `00-investigation.md`. Inputs: your direction (Watch app, two-way alarm sync, earliest OS floor that keeps the latest features, performance, simple but data-full design, all-native Swift, atomic and short files), a full read of WakeTF (`research/06-waketf-learnings.md`), and the platform research on deployment floors and WatchConnectivity (facts below carry their sources in the memory store's `personal/dawn-app/README.md`).

---

## 1. Deployment floor

### The facts

| Fact | Value |
|---|---|
| Xcode 27 can *build* for | iOS 15+, watchOS 9+ |
| Xcode 27 can *run and debug* on | iOS 17+, watchOS 10+ only |
| AlarmKit | iOS 26+, no watchOS version at all |
| RelevanceKit, Liquid Glass, App Intents `supportedModes` | 26+ |
| SwiftData, `@Observable`, TipKit, `Predicate` | iOS 17 / watchOS 10 |
| Interactive Smart Stack widgets, iPhone Live Activities on the wrist | watchOS 11 |
| iPhone adoption, June 2026 (Apple) | iOS 26: 79% of all iPhones, 86% of iPhones under four years; iOS 18: 14% / 11%; earlier: 7% / 3% |
| Watch hardware able to run watchOS 26 | identical to watchOS 11 (Series 6+, SE 2, Ultra) plus Series 11, SE 3, Ultra 3 |
| Watch hardware able to run watchOS 27 | Series 9+, SE 3, Ultra 2+ only |
| Apple watchOS adoption numbers | none published |

### The three candidates

- **iOS 26 / watchOS 26.** No availability gating. AlarmKit unconditional. Drops iOS 18 users (14% today, shrinking monthly now that iOS 27 has shipped). Excludes no Watch hardware compared with watchOS 11.
- **iOS 18 / watchOS 11.** AlarmKit gated. On iOS 18 the phone alarm becomes a time-sensitive local notification: it cannot break the Silent switch, has a 30-second sound cap, no full-screen Stop/Snooze, and is not forwarded to the wrist. That is a different, worse product for a shrinking cohort, plus a second alarm code path to test and defend in App Review.
- **iOS 17 / watchOS 10.** Everything in the previous row plus no interactive Smart Stack widgets. Adds Series 4/5/SE 1 hardware from 2018 to 2020. Lowest floor Xcode 27 can debug at all.

### Recommendation

**iOS 26 / watchOS 26.** The product's core promise, an alarm that rings through Silent and Focus and shows on the wrist, only exists with AlarmKit. Going to iOS 18 buys a degraded alarm for one in seven phones today and fewer every month, at the cost of a permanent fallback path. On the Watch side the 26 floor loses nothing: the hardware list equals watchOS 11's, and 26 is the last release for Series 6 to 8, so that cohort stays populated for years. **Do not pick watchOS 27**; it cuts Series 6 to 8, SE 2 and Ultra 1.

If you still want a lower floor, iOS 18 / watchOS 11 is the only defensible one, and it must ship the notification alarm as a documented "degraded mode". I would not go lower.

---

## 2. Two-way alarm sync

### What can and cannot be synced

- **The alarm definition syncs both ways.** Time, window length, repeat days, enabled flag, gentle-wake settings: edit on either device, the other follows. This is a small document and WatchConnectivity handles it well.
- **Arming the wake window cannot be remote.** `WKExtendedRuntimeSession.start(at:)` must be called while the watch app is *active* (foreground). Apple engineers have said this is by design, including when the watch receives a message from the phone. So the phone can push tomorrow's window to the wrist, but the watch still needs one activation within 36 hours of the window to arm it.
- **The phone alarm reaches the wrist for free.** AlarmKit forwards its alert to the paired Watch, with Stop and the optional secondary button. That is the safety net whether or not the watch session armed.
- **The watch cannot touch the phone's alarms directly.** AlarmKit has no watchOS API. The watch asks the phone over WatchConnectivity.

### Channels

| Content | Mechanism | Why |
|---|---|---|
| Alarm settings document (whole state) | `updateApplicationContext` | Latest-state semantics; delivered when the counterpart wakes; the watch app *is* launched in the background to receive it (via `WKWatchConnectivityRefreshBackgroundTask`), budgeted, no latency promise |
| Event ledger (armed, fired, stopped, skipped) | `transferUserInfo` | Queued, ordered, survives suspension; idempotent by event id |
| "Wake now, cancel the backstop" from inside the window | `sendMessage` with reply, fallback to `transferUserInfo` | Only watch→phone wakes the counterpart; if the message fails, the AlarmKit backstop simply rings at window end, which is the safe failure |
| Complication refresh | `transferCurrentComplicationUserInfo` | Immediate when the complication is on the active face |
| Sleep history across devices (later) | SwiftData + CloudKit | watchOS 10+; never for the nightly arm or cancel |

App Groups do not span iPhone and Watch. `NSUbiquitousKeyValueStore` exists on watchOS 9+ but is slow and iCloud-dependent; it is a backup channel at most.

### The document and its merge

```swift
struct AlarmDocument: Codable, Sendable {
    var schemaVersion: Int
    var alarms: [AlarmDefinition]      // each with id, per-field clocks
    var revision: Int
    var updatedAt: Date
    var origin: Replica                // .phone | .watch
}

struct AlarmDefinition: Codable, Sendable, Identifiable {
    let id: UUID
    var enabled: Stamped<Bool>
    var wakeTime: Stamped<ClockTime>     // hour, minute; the END of the window
    var windowMinutes: Stamped<Int>      // 10...30 on the wrist
    var repeatDays: Stamped<Set<Weekday>>
    var gentleWake: Stamped<GentleWake>
}

struct Stamped<Value: Codable & Sendable>: Codable, Sendable {
    var value: Value
    var updatedAt: Date
    var origin: Replica
}
```

Merge rule on receive, per field: newer `updatedAt` wins; tie → higher document `revision`; tie → phone. If the merged result differs from what the peer sent, republish so both converge. Both clocks are phone-synced, so wall-clock last-writer-wins with a tie-break is sufficient. A version vector is only worth it if a third replica (iPad/Mac via CloudKit) appears. Always bump `revision` and `updatedAt`, because an application context identical to the previous one may be dropped.

### Arming policy (the UX answer to "must open the watch app")

1. **Arm on every activation.** Whenever the watch app becomes active and the next window is within 36 hours, schedule the session and show "Armed 06:30 to 07:00". Opening the app in the morning to look at last night arms tonight for free.
2. **Re-arm from the alarm itself.** The system alarm alert has an **Open** button; tapping it activates the app, which arms the next night. Stop does not open the app.
3. **Nudge only when nothing is armed.** A bedtime Smart Stack widget (RelevanceKit `.sleep` clue) and one local notification, both of which open the app on tap. Any foreground path works: complication tap, widget tap, notification tap, or an App Intent button that opens the app.
4. **Never promise silent auto-arming.** Every path above briefly shows the app. That is Apple's own model and the honest one.

### One night, end to end

```
Evening, phone:   user edits alarm  → document ↑ updateApplicationContext
                  AlarmKit backstop scheduled for windowEnd (.relative, repeat days)
Evening, watch:   WC background task merges document → complication shows "tap to arm"
                  user taps (any path) → app active → session.start(at: windowStart)
                  → event "armed" ↑ transferUserInfo → phone shows "Watch armed"
Pre-window:       CMSensorRecorder buffering; nothing else runs
windowStart:      system launches watch app → handle(session) → motion + HR → 30-s epochs
Decision:         arousal rule fires → notifyUser(haptic) → sendMessage("wake", id)
                  phone cancels AlarmKit backstop; if the message fails, backstop rings at windowEnd
Stop / Open:      outcome logged ↑ transferUserInfo; Open re-arms tomorrow
Morning, phone:   HealthKit stages arrive → night imported → debt and schedule recomputed
```

---

## 3. Architecture: atomic packages, short files

### Principles

- **One reason to change per package, one type per file, files under ~120 lines** (hard stop 150; a file that grows past it is a signal to split, not to scroll).
- **Pure core.** Domain models and algorithms import only Foundation. They compile and test on macOS in seconds, and are shared by the phone, the watch and every widget.
- **Platform adapters behind protocols.** HealthKit, AlarmKit, WatchConnectivity, CoreMotion and the runtime session each get a thin adapter with a protocol and a fake. Views and the core never import a platform framework.
- **Value types and actors.** Swift 6 strict concurrency; sensors are `actor`s; UI state is `@Observable`; no Combine; no third-party dependencies.
- **Atomic UI.** Design tokens → atoms (pill, chip, gauge ring, stage bar) → molecules (alarm card, phase card, night row) → organisms (timeline, hypnogram rail, debt dial) → screens. Each atom is one file and previewable alone.

### Package layout (local Swift packages in `Packages/`)

```
Packages/
  DawnCore/          Foundation only. Models, algorithms, sync document + merge, Tuning.
    Sources/DawnCore/
      Sleep/         SleepSession, SleepNight, SleepStage, SleepNeed, SleepDebt, SleepQuality
      Circadian/     ThreeProcessModel, CircadianAnchors, EnergyPhase, EnergySchedule
      Habits/        Habit, HabitTiming, HabitCatalog
      Alarm/         AlarmDefinition, WakeWindow, AlarmEvent, AlarmOutcome, TriggerReason
      Sensing/       MotionEpoch, ActivityCounts, ColeKripke, ArousalScorer, WakeDecision
      Sync/          AlarmDocument, Stamped, DocumentMerge
      Support/       ClockTime, Weekday, Tuning
    Tests/DawnCoreTests/   Swift Testing; fixture nights as JSON
  DawnHealth/        HealthKit importer (sleepAnalysis → SleepNight), optional writer. iOS + watchOS.
  DawnSync/          WCSession adapter: publish/receive document, ledger, live messages. iOS + watchOS.
  DawnAlarmKit/      AlarmKit adapter (schedule, cancel, reconcile). iOS only.
  DawnWrist/         SmartAlarmSession, MotionStream, HeartRateStream, SensorRecorderBuffer, ArousalMonitor. watchOS only.
  DawnUI/            Tokens, atoms, molecules, organisms. All platforms. Previews per file.
Apps/
  Dawn/              iOS app: Features/{Home,Progress,Energy,Tools,Guidance,Alarm,Onboarding}, App/, Services/ (composition root)
  DawnWatch/         watchOS app: Features/{Tonight,Window,Alerting,LastNight}, App/
  DawnWidgets/       iOS widgets + AlarmKit Live Activity (required by AlarmKit for countdown presentation)
  DawnWatchWidgets/  complications and Smart Stack widget
Scripts/, Makefile, Dawn.xcworkspace or a single .xcodeproj referencing the packages
```

Ported from WakeTF (MIT, attributed): `SmartAlarmSession` (from `ExtendedRuntimeController`), `WakeWindow.next(after:)` (from `AlarmScheduleCalculator`), `MotionFeatures` extraction, `ArousalScorer` with its median/MAD baseline, `HeartRateStream`, validation and trigger-reason enums, and the three test files as the seed corpus. WakeTF's 438-line coordinator becomes four files: the session, the monitor loop, the pure decision, and the outcome log.

### Data flow

- One `@Observable` store per feature, fed by the core's pure functions. Views read; intents write through the store.
- The **schedule is precomputed** on a 5-minute grid whenever a night changes, and cached; screens draw from the grid. No model evaluation during scrolling.
- The **timeline and hypnogram rail draw with `Canvas`** (SleepChartKit's approach); Swift Charts for the Progress bars and trend lines where interactivity is wanted.
- Morning import runs in a `BGProcessingTask` or on launch; nothing sleep-related runs in the background otherwise.
- Inside the 30-minute session the watch does one thing: fixed-rate motion sampling into 30-second epochs and a cheap rule. Sustained CPU gets the session cancelled.

### Design language ("simple yet data-full")

- Dark-first, one accent, system fonts, native components (`Gauge`, `Chart`, `List`, `TabView`, sheets). Liquid Glass materials on 26 for the dock and cards.
- Every screen has one number that matters at the top (debt, energy now, window), then the dense layer beneath (timeline, rail, chips). Rise's layout is the reference; the difference is restraint.
- Tokens in `DawnUI/Tokens`: colour roles (stage colours, band colours, accent), spacing scale, radii, type ramp. No literal colours in views.

### Coding rules (to become `CLAUDE.md` in the repo)

- Swift 6, strict concurrency complete, no `@unchecked Sendable` without a comment naming the lock.
- One type per file; file name equals type name; under ~120 lines.
- No third-party dependencies. No Combine. No singletons except the platform ones Apple provides.
- Every platform boundary has a protocol and a fake; tests cover the core and the fakes, not Apple.
- Tunable constants live in `Tuning` next to their tests; prose docs never restate them.
- Strings through `String(localized:defaultValue:)` into an `.xcstrings` catalogue.
- No analytics, no network, no raw sensor persistence; release logs carry no health values.

---

## 4. Spike 0, refined

A throwaway iPhone + Watch project, on real hardware, that answers what documentation cannot:

1. In which app state does `handle(_ session:)` launch the app, and can it schedule the next session from there? (Docs imply no; confirm the error.)
2. Is `WCSession.isReachable` true from inside a smart-alarm session, so `sendMessage` can cancel the phone backstop live?
3. Does `CMSensorRecorder` deliver samples across the hours when watchOS's own sleep tracking is running?
4. How many passive heart-rate samples arrive inside a 30-minute session without a workout session?
5. What does an AlarmKit alert look like on the wrist: does the Watch haptic fire, is Snooze offered, does a wrist Stop dismiss the phone?
6. Does an App Intent button with `supportedModes: .foreground` leave the app `.active` in time to schedule from `scenePhase`?
7. Is an unchanged application context dropped (so `revision` must always bump)?

Each answer goes into `personal/dawn-app/README.md` in the memory store.

---

## 5. Decisions (taken 2026-09-30)

1. **Floor: iOS 26.0 / watchOS 26.0.** No availability gating.
2. **Test hardware: Apple Watch SE 2 on watchOS 26.6.** S8 SiP, no always-on display, no high-rate `CMBatchedSensorManager`; everything else we need is present. watchOS 27 is out of reach on this device, so 27-only features are out of scope.
3. **Six packages, four app targets**, as laid out above.
4. **Name: "Dawn: Smart Alarm"**, short name "Dawn". Bundle prefix: see the plan.

Simulators: no runtimes are installed on this Mac yet (Xcode → Settings → Components). Alarm work needs a physical Watch regardless.
