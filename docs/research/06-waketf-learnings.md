# What we learn from WakeTF (acwo/waketfapp, MIT)

Read in full on 2026-09-30 (13 commits, ~2,340 lines of app Swift + ~600 lines of tests). A clone lives in the session scratchpad; the upstream is https://github.com/acwo/waketfapp.

## 1. Facts that set expectations

- **Watch-only.** `WKWatchOnly = true`, no iPhone companion, no WatchConnectivity, no sync, no repeat schedule. One alarm plan at a time, stored as JSON in `UserDefaults`.
- **Targets watchOS 11, Swift 6, `SWIFT_STRICT_CONCURRENCY = complete`.** Nothing in the code needs watchOS 11: it uses `ObservableObject`/Combine, `@WKApplicationDelegateAdaptor`, `symbolEffect` and the two-parameter `onChange` (both watchOS 10). "Series 6 or later" in the README is a tested-on statement, not a sensor requirement.
- **Built largely without Xcode.** `DEVICE_TESTS.md` lists 23 device scenarios, all "Not tested"; the README later says "tested on Series 10". Treat it as a well-structured sketch of the right pattern, not as proof that the pattern works end to end. Our spike 0 has to prove it.
- **Docs drifted from code.** `ARCHITECTURE.md` says thresholds 0.80/0.68/0.56, warm-up ~150 s, strong burst 2.0 g, bursts normalised to 5. Code says 0.52/0.38/0.25, 60 s, 1.2 g, normalised to 3. Lesson: tunable constants belong in one typed place with the tests, and prose docs should not restate them.

## 2. The session pattern (copy this)

- `Info.plist`: `WKApplication`, `WKBackgroundModes: [alarm]`, `NSMotionUsageDescription`, `NSHealthShareUsageDescription`. Entitlement: `com.apple.developer.healthkit`.
- `ExtendedRuntimeController` (80 lines) owns one `WKExtendedRuntimeSession`: create, set delegate, `start(at:)`; delegate callbacks `didStart` (record `expirationDate`), `willExpire` (fire now), `didInvalidateWith reason:error:`. Alarm = `session.notifyUser(hapticType: .notification) { _ in 3.0 }` (repeat every 3 s until Stop).
- `WKApplicationDelegate.handle(_ session:)` on relaunch: attach the resumed session, set the delegate at once (otherwise the system ends it), and if `state == .running` start monitoring immediately.
- Deadline = `min(latestDate, session.expirationDate − 5 s)`; a `Task.sleep` deadline fires the fallback; `willExpire` is a second fallback.
- Validation: window 5 to 30 min, earliest at least 60 s in the future, one alarm at a time.
- Re-arming: the old session is invalidated first. WakeTF then sleeps one second and hopes; we should wait for the `didInvalidate` callback instead.

## 3. Sensor pipeline (adapt this)

- **Motion**: `CMMotionManager.startDeviceMotionUpdates` at 10 Hz onto a serial `OperationQueue` (QoS `.userInitiated`); rolling 15-second buffer of `userAcceleration` (gravity removed) and `rotationRate`. Features per evaluation: RMS magnitude, variance, peak, burst count (magnitude > 0.4 g), time since last burst, and an "orientation change" that is really the rotation-rate delta between the first and last sample (misnamed; rename).
- **Heart rate**: `HKAnchoredObjectQuery` on `.heartRate` with a "last 5 minutes" predicate and an `updateHandler`; keeps the last 20 samples; a sample is "fresh" if under 5 min old; baseline = median of fresh samples; trend = mean of the last three deltas (rising if > +2 bpm, falling if < −2).
- No pre-window context: the baseline is computed inside the window after three evaluations (45 s), so the first minute is blind. Our design adds `CMSensorRecorder` buffering before the window and a night HR baseline.
- Sensors are `@unchecked Sendable` classes guarded with `NSLock`; features are `Sendable` structs. Reasonable, but an `actor` per sensor is cleaner under Swift 6.

## 4. Scoring and decision rule (re-tune, keep the shape)

- Evaluate every **15 s**. Scorer is a pure `struct` (`WakeScorer`) with a `Baseline` (motion RMS median + MAD, HR median) updated from the last 8 evaluations.
- Motion score = 0.35·clamp((rms − median)/MAD ÷ 2.5) + 0.25·min(bursts/3, 1) + 0.25·min(peak/0.8, 1) + 0.15·min(rotationDelta, 1).
- HR score = 0.6·clamp(rise/15 bpm) + 0.4 if rising (0.1 if stable).
- Combined = 0.75·motion + 0.25·HR when HR is fresh, else motion only; no motion → never triggers early.
- Fire when combined ≥ threshold for **2 consecutive evaluations** (30 s), or peak ≥ 1.2 g after a 30 s start guard. Warm-up 60 s. Thresholds: low 0.52, normal 0.38, high 0.25.
- This is an **arousal detector** ("you are stirring"), not a sleep-stage classifier. That is honest and matches what every consumer smart alarm actually does. Our v1 rule (appendix 04 §6) adds 30-s epoch activity counts and HR-vs-night-baseline on top of this shape.

## 5. Structure and tests (keep the pattern, split the big file)

- Layout `App/ Models/ Features/ Services/ Support/ Resources/`; one type per file for models and services; views are small except `AlarmSetupView` (332 lines, three pickers with linked-time logic).
- `AlarmCoordinator` (438 lines, `@MainActor ObservableObject`) mixes five jobs: state machine, session orchestration, sensor start/stop, evaluation loop, outcome recording. Split it.
- Protocols for every service (`AlarmStoreProtocol`, `MotionMonitorProtocol`, `HeartRateMonitorProtocol`) with fakes in tests. Keep.
- 27 XCTest cases, all pure logic: next-occurrence across midnight, validation bounds, scorer (warm-up, stale HR ignored, two-window rule, threshold ordering, baseline update), state transitions and persistence. Good seed corpus; port to Swift Testing.
- `Localizable.xcstrings` with `String(localized:defaultValue:)` throughout. Keep.
- Privacy posture (no network, no analytics, no raw sensor persistence, release logs carry no health values) is exactly ours. Keep the `PRIVACY.md` idea.

## 6. Gaps against Dawn's needs

| Gap | Consequence | Our answer |
|---|---|---|
| No fallback if the session is rejected or dies | Sleeping through a failed session | AlarmKit alarm at window end on the phone; system forwards it to the Watch |
| No repeat days, no schedule | Arm by hand every night with a full setup | Alarm definition with days syncs from the phone; watch shows a one-tap "Arm tonight" |
| No phone app or sync | Cannot set on one device and use on the other | WatchConnectivity-backed shared alarm document (see the direction doc) |
| No pre-window baseline | First minute blind, HR baseline from 3 samples | `CMSensorRecorder` for the hours before the window; night HR median |
| No epoch model | Movement-only trigger | 30-s epochs with activity counts, Cole-Kripke score as an extra feature |
| Coordinator does everything | Hard to read and test | Atomic pieces: `SmartAlarmSession`, `ArousalMonitor`, `WakeDecision`, `AlarmOutcomeLog` |
| `ObservableObject` + Combine | Extra boilerplate | `@Observable` |
| Stale prose constants | Silent divergence | Constants live in one `Tuning` struct beside the tests |

## 7. What to port (MIT, keep attribution)

- `ExtendedRuntimeController` → `SmartAlarmSession` (near verbatim, plus invalidate-then-await).
- `AlarmScheduleCalculator.resolveNextOccurrence` → `WakeWindow.next(after:)` including the cross-midnight case and its tests.
- `MotionMonitor` feature extraction → `MotionFeatures` (rename orientation → rotationDelta), add epoch counts.
- `WakeScorer` + `Baseline` (median/MAD) → `ArousalScorer` with our own `Tuning`.
- `HeartRateMonitor` → `HeartRateStream`.
- `AlarmValidation`, `AlarmTriggerReason`, `AlarmOutcome` as the seed of our alarm model.
- The three test files as the seed corpus.
