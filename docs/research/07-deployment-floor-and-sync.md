# Deployment floor and iPhone-Watch sync (agent research, 2026-09-30)

Condensed; the direction doc (`../01-architecture-direction.md`) carries the conclusions. UNCONFIRMED items are listed at the end.

## Availability matrix
| API | Min iOS | Min watchOS |
|---|---|---|
| AlarmKit | 26.0 | none |
| WKExtendedRuntimeSession smart alarm, start(at:), notifyUser | n/a | 6.0 (WKApplicationDelegate.handle: 7.0) |
| CMSensorRecorder | 9.0 | 2.0 |
| CMBatchedSensorManager (needs HKWorkoutSession; Series 8/Ultra+ for high rate) | — | 10.0 |
| HealthKit sleep stages | 16.0 | 9.0 |
| healthkit.background-delivery entitlement | 15.0 | 8.0 |
| WatchConnectivity | 9.0 | 2.0 (.backgroundTask(.watchConnectivity) 9.0) |
| SwiftData (+CloudKit), @Observable, TipKit, Predicate, ContentUnavailableView | 17.0 | 10.0 |
| Swift Charts, NavigationStack, Gauge (watch 7) | 16.0 | 9.0 |
| Interactive widgets | 17.0 | Smart Stack interactive from 11.0 |
| ActivityKit / Live Activities | 16.1 | shown in Smart Stack from 11 |
| RelevanceKit | 26.0 | 26.0 (only effective on watchOS) |
| Liquid Glass glassEffect | 26.0 | 26.0 |
| App Intents openAppWhenRun | 16 (deprecated 26) | 9 (deprecated 26) → supportedModes 26 |
| UNNotificationInterruptionLevel.timeSensitive (breaks Focus, NOT Silent) | 15.0 | 8.0 |
| #Preview, @Entry | back-deployed | back-deployed |
| Swift Testing | Xcode 16+ host; iOS 13+ targets | |

## Adoption (Apple, devices transacting 2026-06-07)
- iPhone all: iOS 26 79%, iOS 18 14%, earlier 7%. Under four years: 86 / 11 / 3.
- No watchOS numbers published; no credible third-party split found.
- Snapshot predates iOS 27 (Sept 2026); by ship time iOS 26 is N-1.

## Xcode 27
- Deployment targets: iOS 15-27, watchOS 9-27. Device support and simulators: iOS 17+, watchOS 10+ only. macOS Tahoe 26.6 required. Swift 6.4.
- Local check on this Mac: iPhoneOS27.0.sdk min 15.0, WatchOS27.0.sdk min 9.0.

## Watch hardware by watchOS
- 10: Series 4-9, SE 1/2, Ultra 1/2.
- 11: Series 6-10, SE 2, Ultra 1/2 (dropped S4, S5, SE 1).
- 26: same as 11 plus Series 11, SE 3, Ultra 3.
- 27: Series 9, 10, 11, SE 3, Ultra 2, Ultra 3 only.
- Accelerometer, HR, CMSensorRecorder on every model. WakeTF's "Series 6+" is the watchOS 11 hardware list, not a sensor requirement.

## WatchConnectivity mechanisms
- updateApplicationContext: latest state, replaces previous; delivered when counterpart wakes; the WATCH app IS launched in the background (WKWatchConnectivityRefreshBackgroundTask; budgeted, no latency promise); iOS app also launched in background.
- transferUserInfo: queued, ordered, survives suspension; cancellable.
- sendMessage: immediate, needs isReachable; watch→phone wakes the iOS app; phone→watch never wakes the watch app; watch reachable only when foreground or high-priority background (workout; smart-alarm session UNCONFIRMED). Keep under ~65 KB.
- transferFile: queued; file deleted after didReceiveFile returns.
- transferCurrentComplicationUserInfo: immediate, 50/day when complication on active face.
- Delivery is serial and in order; WC is opportunistic and "cannot be the primary data source".
- App Groups do NOT span iPhone-Watch. NSUbiquitousKeyValueStore available on watchOS 9+ (1 MB, iCloud latency). CloudKit watchOS 3+; SwiftData+CloudKit watchOS 10+.

## Arming facts
- start(at:) must be called while the app is in the foreground and active; one scheduled session; <=36h ahead; >1 min in the past fails.
- Apple DTS 794730: by design, foreground-only; file feedback. Apple engineer 760402: scheduling on receipt of application context fails with WKExtendedRuntimeSessionErrorDomain Code=3 "The app must be active and before applicationWillResignActive to start or schedule".
- Notification action, WKApplicationRefreshBackgroundTask, WC background task, phone message: all NOT active → cannot arm.
- handle(_ session:) self-perpetuation: strongly implied NO (app launched, not active); spike to confirm.
- Works: alarm alert Open button (app active → schedule next), notification tap / .foreground action, Smart Stack widget tap (11+), complication tap, App Intent with supportedModes .foreground (26) / openAppWhenRun (11-26) — schedule from scenePhase == .active, not perform() (UNCONFIRMED timing).
- HKHealthStore.startWatchApp(with:) is workout-only.

## AlarmKit on the wrist
- System forwards the alert presentation to a paired Watch (title, app name, Stop, optional secondary button). Third-party report: alarm sounds and can be stopped from the wrist without a watch app.
- UNCONFIRMED: snooze on wrist, watch haptic, cross-device dismissal, stopIntent skipped on hardware-button dismissal (SuperAlarm README claim). Design implication: never rely on stopIntent to know the user is up.
- No watchOS AlarmKit API; watch goes through WatchConnectivity.

## Unconfirmed
1. watchOS adoption split. 2. iOS 17 share of the 7% "earlier". 3. App state on handle(_ session:) launch. 4. App Intent .foreground timing on watchOS. 5. isReachable during a smart-alarm session. 6. AlarmKit wrist behaviours above. 7. WC dropping identical application contexts. 8. requestAutoLaunchAuthorizationStatus purpose (likely underwater auto-launch). 9. Any WC/AlarmKit changes in 26/27 (none found).
