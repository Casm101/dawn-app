# iOS 26 / watchOS 26 feasibility (agent report, 2026-09-30)

## Headline verdict
"Decide fire time at the last minute from current sleep stage" is FEASIBLE WITH CAVEATS, only in this shape:
1. Real-time stage estimation must be OUR OWN, on Apple Watch, inside a WKExtendedRuntimeSession of type smart alarm (30-min background window, schedulable <=36h ahead). Apple's HealthKit stage data arrives after the session ends; useless live.
2. The WATCH is the primary alarm (notifyUser(hapticType:) -> repeating haptics + system alarm alert).
3. AlarmKit on iPhone is the SAFETY NET: fixed alarm at END of window; watch messages phone (WCSession.sendMessage wakes iOS app in background); phone cancels window-end alarm and schedules a new one ~1 min out. AlarmKit cannot be moved in place and runs no app code at fire time.
4. UX cost: user must open the watch app each night to arm the session (Apple DTS confirmed no unattended scheduling); window capped at 30 min.

## 1. AlarmKit — feasible with caveats
- iOS 26/iPadOS 26/Catalyst only; NOT watchOS. Overrides Focus + silent; alert forwarded to paired watch; survives reboot; unlimited alarms; "not replacements for critical alerts". https://developer.apple.com/documentation/alarmkit/scheduling-an-alarm-with-alarmkit ; https://wwdcnotes.com/documentation/wwdc25-230-wake-up-to-the-alarmkit-api/
- API: AlarmManager.shared.requestAuthorization(); NSAlarmKitUsageDescription required; schedule(id:configuration:) -> Alarm; AlarmConfiguration(countdownDuration:schedule:attributes:stopIntent:secondaryIntent:sound:); Alarm.Schedule .fixed(Date) | .relative(time hour:minute, repeats .never|.weekly([Weekday])) minute granularity; CountdownDuration(preAlert:postAlert:) postAlert = snooze interval; cancel(id:), stop(id:), pause/resume; AlarmPresentation(alert:countdown:paused:); Alert(title:secondaryButton:secondaryButtonBehavior: .countdown (snooze) | .custom (Open)); buttons run LiveActivityIntent. Widget extension REQUIRED if countdown presentation used ("system may unexpectedly dismiss alarms"). alarmUpdates only while app running (stops ~30s after backgrounding). https://developer.apple.com/documentation/alarmkit/alarmmanager
- Custom sound: sound: AlertConfiguration.AlertSound.named("file"), bundle or Library/Sounds, < 30 s; looping fixed iOS 26.1. https://developer.apple.com/forums/thread/797172
- Dynamic fire time: NO update API; cancel + schedule. AlarmError.maximumLimitReached (limit undocumented). App code does NOT run at fire time (SpringBoard presents). Scheduling from background works (PushAlarm schedules from NSE). Min lead time undocumented (~60 s community). Bug iOS 26.1-26.5: fixed alarms occasionally fire at 00:00/late (FB22327481 etc.) -> prefer .relative; keep watch haptic primary. https://developer.apple.com/forums/thread/820388

## 2. Pre-AlarmKit workarounds — not recommended
- Critical alerts need Apple entitlement (health/safety only); consumer alarm does not qualify.
- Background audio keep-alive: Guideline 2.5.4 rejection boilerplate; 2.4.2 "should not encourage placing the device under a mattress or pillow while charging". Exception: actually recording audio (mic mode) is legitimate.

## 3. HealthKit sleep — not real-time; fine for morning
- HKCategoryValueSleepAnalysis: inBed, awake, asleepCore (N1/N2), asleepDeep, asleepREM, asleepUnspecified; allAsleepValues. Watch awake samples only between two sleep samples.
- Apple paper: binary sleep/wake written if session 1-3h; full stages if > 3h — evaluated only after session ends -> writes are POST-HOC after wake-up. Developers report samples "many minutes after waking". Latency not published.
- Background delivery needs com.apple.developer.healthkit.background-delivery entitlement; some types hourly-max; watchOS 4 wakes/hour budget only with complication on active face.
- Requirements for Apple stages: Sleep Focus on, worn >= 1h, >= 30% battery; iOS 18+ tracks naps.

## 4. watchOS companion — feasible with caveats
- Extended runtime session types: Self care (frontmost, 10 min), Mindfulness (frontmost, 1h), Physical therapy (background, 1h, not schedulable), SMART ALARM (background, schedulable, 30 min). WKBackgroundModes: alarm; one session type per app. https://developer.apple.com/documentation/watchkit/using-extended-runtime-sessions
- start(at:) within 36h, called while app ACTIVE; one session at a time; invalidate() also needs active app; system relaunches app into handle(_:) — must set delegate or session ends; must call notifyUser(hapticType:repeatHandler:) (repeat default 3s, max 60s) or system warns and offers to disable; wrist-down keeps running (WWDC19 251).
- DTS 2025: no unattended scheduling; recommends AlarmKit for fixed alarms. Errors: mustBeActiveToStartOrSchedule, scheduledTooFarInAdvance, notApprovedToSchedule, exceededResourceLimits. requestAutoLaunchAuthorizationStatus (watchOS 9) semantics unconfirmed. https://developer.apple.com/forums/thread/794730
- Sensors: CMMotionManager works while process alive; CMSensorRecorder 50Hz up to 12h, 3-day retention (all-night buffering; one blog claims zero samples during watchOS's own sleep detection — unverified); CMBatchedSensorManager workout-only. HR: frequent HR (1-5s) only via HKWorkoutSession (affects rings, battery); otherwise anchored query gets little; haptic engine pauses HR gathering. Practical: accelerometer-driven model in the 30-min window, passive HR weak feature; no all-night workout session. High CPU -> exceededResourceLimits.
- Waking phone: WCSession.sendMessage wakes iOS app in background; isReachable during extended runtime session not documented. HKHealthStore.startWatchApp(with:) is workout-only (off-label risk). Precedent app "Smart Alarm Clock for Watch" (2019) required nightly arming; since pulled.

## 5. Phone-on-mattress — mic mode feasible; accelerometer-in-background not supported
- CMMotionManager stops when suspended -> accelerometer mode needs foreground (Sleep Cycle's accel mode). Mic mode (playAndRecord session, muted output node keeps it alive; handle interruptions; on-device classify, discard PCM) is a legitimate audio background use. https://dev.to/sleeptrace/field-notes-all-night-audio-recording-on-ios-without-dying-in-the-background-19c
- iPhone CMSensorRecorder availability device-dependent; retrospective. Location keep-alive: do not use.
- Phone-only smart alarm: app alive via mic session; cancel/reschedule AlarmKit from live process.

## 6. Background execution — nothing keeps a smart alarm alive
- BGAppRefreshTask 30s; BGProcessingTask minutes overnight while charging, killed on use; BGContinuedProcessingTask (iOS 26) foreground-started user-visible. Use BGProcessingTask for morning analysis only.

## 7. Apple Sleep schedule — not readable
- No HealthKit identifiers for schedule/goal/score. RelevanceKit .sleep(...) clue for Smart Stack needs sleepAnalysis read. Can WRITE sleepAnalysis samples; Apple Sleep Score consumes third-party data.

## 8. Widgets / Live Activities / complications — standard WidgetKit
- AlarmKit alert/countdown rendered via ActivityKit; widget extension mandatory for countdown. iPhone Live Activities appear in watch Smart Stack (watchOS 11+). RelevanceKit clues (.sleep, .date, .fitness). Complication on active face unlocks HK background budget.

## 9. iOS 27 / watchOS 27 (WWDC 8 June 2026) — nothing architectural
- AlarmKit unchanged; still no watchOS AlarmKit. HealthKit: HR zones, menopausal types, limited-vs-full history permission; nothing for sleep. User-facing: separate alarm/timer volume; holiday alarm prompt; time-zone support in Sleep; Health redesign. WKExtension deprecated -> WKApplicationDelegate.handle(_ session:).

## Recommended architecture
Watch (primary): WKBackgroundModes [alarm]; user opens watch app at bedtime (or deep-link from notification) -> session.start(at: windowStart), CMSensorRecorder 12h, tell phone. At windowStart watchOS launches into handle(_:) -> delegate, CMMotionManager 25-50Hz, 30-s epoch actigraphy/respiration model, optional passive HR. On light-sleep or hard stop before expirationDate -> notifyUser(hapticType: .notification, repeatHandler:) + WCSession.sendMessage(["wake": true]). Morning: write own sleepAnalysis samples.
iPhone (safety net + UI): on bedtime confirmation AlarmManager.schedule(.alarm(schedule: .fixed(windowEnd)), custom <30s sound, widget ext for Live Activity). On watch "wake" message: cancel(windowEnd), optionally schedule new fixed alarm >= 60s out or .timer(60). If message never arrives: watch haptic early + phone at window end (acceptable double-alarm). Optional phone-only: mic-based tracking with real playAndRecord session + same AlarmKit dance.
Morning: BGProcessingTask/app launch reads Apple stages; RelevanceKit .sleep clue surfaces summary widget.

## Unconfirmed
AlarmKit min lead time; schedule(id:) replace-in-place; alarm count limit; sleepAnalysis background-delivery throttling + write latency; WCSession.isReachable inside smart-alarm session; requestAutoLaunchAuthorizationStatus meaning; CMSensorRecorder during Apple sleep detection; Sleep Cycle support articles (blocked).
