# Dawn — investigation findings

Date: 2026-09-30. Goal: an open-source iOS (+ watchOS) app covering what Rise does — sleep tracking, sleep debt, a circadian energy schedule, timed habits, and a smart alarm that picks the best moment inside a wake window based on the sleeper's current sleep stage.

This document is the summary; `01-architecture-direction.md` turns it into a direction (floor, sync, package layout). The evidence sits in `docs/research/`:

| # | File | What it holds |
|---|---|---|
| 01 | `research/01-screenshot-analysis.md` | What the seven supplied screenshots show, screen by screen, and the requirements read off them |
| 02 | `research/02-rise-feature-inventory.md` | Full Rise feature inventory from its help center, release posts, store listings and reviews |
| 03 | `research/03-ios-platform-constraints.md` | What iOS 26 / watchOS 26 (and 27) allow: AlarmKit, watch smart-alarm sessions, HealthKit timing, background rules |
| 04 | `research/04-sleep-science-and-algorithms.md` | Sleep debt, two-/three-process and SAFTE models, habit timing evidence, stage-detection algorithms, alarm decision rule, quality score |
| 05 | `research/05-prior-art.md` | Open-source code to reuse or port, with licences |
| 06 | `research/06-waketf-learnings.md` | Full read of WakeTF (MIT watch smart alarm): what to port, what to change |
| 07 | `research/07-deployment-floor-and-sync.md` | API availability matrix, adoption numbers, WatchConnectivity mechanics, arming facts |

---

## 1. The short version

1. **Rise is a sleep-debt and circadian-schedule product with an alarm bolted on, not a sleep-stage tracker.** It computes no stages itself. It imports Apple Watch stages from HealthKit for display, estimates sleep from phone motion otherwise, and its "smart alarm" is primarily a debt-aware alarm. Its "lighter phase" window length and sensor are unpublished. On iOS 26.1+ Rise's phone alarm runs on AlarmKit; its Watch alarm must be armed by hand every night on the wrist and is not synced with the phone.

2. **What you asked for (wake at the best moment inside a range based on live sleep stage) is feasible, but only on the Apple Watch, and only in one shape.** Apple's own stage data lands in HealthKit after the night ends, so it cannot drive a live decision. The only background runtime that can is the watchOS "smart alarm" extended runtime session: schedulable up to 36 hours ahead, runs for at most 30 minutes, must be armed from the foreground watch app each night, and must end in a haptic. The phone side uses AlarmKit as a safety net: schedule a fixed alarm at the end of the window, and when the watch decides to wake you early it messages the phone, which cancels that alarm. No app code runs when an AlarmKit alarm fires, so "move the alarm earlier" is always cancel-plus-reschedule.

3. **Phone-only smart alarm is second-class.** Background accelerometer tracking is not possible on iOS (motion updates stop when the app suspends). The only legitimate keep-alive is a real microphone recording session, which is how Sleep Cycle works. That path is buildable but is a separate mode with worse stage accuracy and App Review sensitivity.

4. **The science is well documented and the maths is small.** Sleep debt (14-night, recency-weighted), the three-process alertness model, DLMO and melatonin-window offsets, Cole-Kripke and van Hees actigraphy, and the alarm decision rule all fit in a few hundred lines of Swift and are backed by MIT/BSD/Apache reference implementations.

5. **Honest caveat on the headline feature.** The only controlled trial of a stage-aware alarm found lower *perceived* grogginess but no measurable performance gain, and PSG studies show phone apps detect stages poorly. Consumer wearables reach moderate agreement (kappa 0.4 to 0.68). The feature is worth building because people value it and the watch signal is decent, but the app should not overclaim.

6. **Toolchain is ready.** This Mac has Xcode 27.0 with iOS 27 and watchOS 27 SDKs and Swift 6.4. Minimum targets of iOS 26 / watchOS 26 unlock AlarmKit and the current extended-runtime APIs. No simulator runtimes appear installed yet; a physical Watch will be needed for the alarm work regardless.

---

## 2. What Rise actually is (product model)

Rise's model, in one loop:

- **Sleep need** (a personal baseline, ~8h, learned slowly from rebound nights) minus **sleep obtained** (only asleep time, naps included) over a **rolling 14 nights, recency-weighted** = **sleep debt**, shown as one number and a band (screenshots: "Okay 8.7 hrs", ring markers "Great 5 / Super 0").
- Sleep debt maps to **Energy Potential %** (100% at zero debt). It does not shift the circadian phases, it flattens them.
- **Wake time goal** anchors a **circadian schedule** (grogginess → morning peak → afternoon dip → evening peak → wind-down → Melatonin Window → wake zone) derived from a SAFTE-style effectiveness model plus a light-driven phase model. The schedule updates daily and drifts as your actual sleep times drift.
- **Habits** are chips pinned to that schedule ("Avoid caffeine" ~10h before the Melatonin Window, "Take melatonin", "Rate sleep quality" 90 min after wake, and ~20 more), each with an optional notification.
- **Smart Schedule** projects how many days of following the recommended bed/wake times it takes to get debt into the good band ("GREAT IN 4 days").
- The **alarm** is a repeating alarm with days, a gentle-wake ramp, and a debt indicator showing whether the chosen time adds to or reduces debt (the red bar under the alarm card, with the grey "Wake window" band being the recommended wake zone).
- **Data sources**, in priority order: Apple Health (Watch and any third-party app writing sleep), phone motion "Nightstand" mode, phone-on-mattress mode (armed nightly), manual entry. Rise reads Health and never writes to it.

Everything else (Tools: sounds, guided relaxation, brain dump, partner connect; Guidance: daily articles; AI coach; telehealth) is content layered on top.

Rise's weaknesses, as its users report them, are the things an open-source version can simply not have: hard paywall, billing surprises, no data export, no trends beyond 14 nights, unsynced phone/Watch alarms, no per-day wake goals, no nap toggle, and a schedule that ignores a fixed early alarm.

---

## 3. Needs and wants

Priorities use MoSCoW. "Screens" refers to the supplied screenshots; "Rise" to the inventory in appendix 02.

### Must have (v1)

| Need | Evidence | Notes |
|---|---|---|
| Import sleep sessions and stages from HealthKit, with source attribution | Screens 3-5, Rise §5 | Read `sleepAnalysis` (inBed / awake / asleepCore / asleepDeep / asleepREM / asleepUnspecified). Apple Watch stages arrive after wake; that is fine for the morning report. |
| Manual sleep and nap entry; edit a night; insert awake time by splitting a segment | Screens 4-5 "Press to add awake time", Rise §5 | Rise allows edits 14 days back; entries under 20 min not editable. |
| Sleep need (seeded, slowly learned, user-adjustable) | Rise §2 | Seed 8h15; learn from alarm-free nights; clamp 5h to 11.5h. |
| Sleep debt: 14-night recency-weighted, naps count, bands with a daily delta | Screen 1 "Okay +0.4hrs", Rise §2 | Rise's decay curve is unpublished; a geometric decay with last night = 15% reproduces its stated behaviour. |
| Energy schedule: labelled phases, energy curve, "now" marker, per-phase change vs yesterday | Screens 2-3 "Morning peak · 6m shorter", Rise §3 | Three-process alertness model with DLMO-anchored phases. |
| Energy Potential % (current) and a day-level score | Screens 1 and 3 (57% vs "Okay 66%") | Two numbers appear; likely "now" vs "today". Decide our own definition. |
| Habit chips on the timeline with notifications | Screens 5-6, Rise §6 | Start with the evidence-backed set: morning light, caffeine cutoff, meal cutoff, alcohol cutoff, dim lights, wind-down, melatonin (supplement), rate sleep quality. |
| Smart alarm: time, repeat days, on/off, multiple alarms, gentle wake, window guidance, debt warning | Screen 7, Rise §4 | AlarmKit on the phone for reliability. |
| **Stage-aware wake inside a window on Apple Watch** | Your requirement; Rise §4 (its Watch alarm) | Watch smart-alarm session, max 30 min window, armed nightly. See §5. |
| Progress: 14-day Sleep Times chart, Sleep Debt trend, Sleep Quality ratings, list of nights | Screen 6, Rise §7 | Extend beyond 14 days; users ask for it and it costs nothing. |
| Smart Schedule projection ("Great in N days") | Screen 6 | Simulate the debt model forward with recommended bed/wake. |
| Persistent dock: alarm pill, sleep-source pill, quick add | All screens | |
| Onboarding: bed/wake times, sleep need seed, permissions (Health, Motion, Notifications, AlarmKit) | Rise §9 | Keep it to a handful of screens. |
| Local-first storage, data export | Rise complaints | SwiftData or GRDB; export JSON/CSV; optionally write our own `sleepAnalysis` samples to Health. |

### Should have (v1.x)

- Phone-motion "Nightstand" sleep detection for users without a Watch (Rise's default source, "80% accurate"). Needs a spike: iOS gives no background accelerometer, so this is tappigraphy (screen on/off, first/last touch) plus `CMSensorRecorder` where available, not live motion.
- Widgets (home, lock screen) and a Watch complication showing the current phase and time left in it; RelevanceKit `.sleep` clue for the Smart Stack.
- Sleep quality self-rating prompt 90 min after wake, and a computed quality score (NSF thresholds).
- Calendar export of the phases (EventKit).
- Peaks & Dips notifications.
- Per-day wake goals (a top Rise request).
- Snooze policy: snooze turns the alarm into a plain alarm; backup alarm 20 min after window end.

### Could have (v2+)

- Phone-only smart alarm via microphone mode (Sleep Cycle style). Separate, review-sensitive, lower accuracy.
- Phone-on-mattress accelerometer mode (foreground only; Guideline 2.4.2 wording care).
- Light-driven phase model (St Hilaire / Forger) using time-in-daylight and steps from Health as the light proxy.
- Sleep sounds and short guided relaxations (CC0 audio).
- Partner sharing, trends beyond 14 days, notes on nights, jet-lag mode.
- Live Activity during the wake window (AlarmKit requires a widget extension anyway if countdown presentation is used).

### Will not do

- Any paywall, account, or server. Local-first; iCloud sync at most.
- AI coach, telehealth, article feed.
- Silent-audio or location keep-alive hacks (App Review rejection risk and battery cost).
- Critical-alert entitlement (Apple will not grant it to an alarm app; AlarmKit replaces it).

---

## 4. The smart alarm, honestly

**What Rise does.** On iOS 26.1+ Rise's phone alarm is an AlarmKit alarm. AlarmKit runs no app code at fire time, so a phone-only AlarmKit alarm cannot react to sleep stage at the last minute unless a live process is around to cancel and reschedule it. Rise's Watch alarm is armed nightly on the wrist and rings with haptics, which is the signature of the watchOS smart-alarm session. Its window length and sensor are unpublished; users guess "15 minutes either side".

**What the evidence supports.** Waking from N3 (deep) produces the worst sleep inertia; waking from N2 or REM is easier. Consumer wearables separate light from deep moderately well. The one controlled trial of a stage-aware alarm showed people felt less groggy but did not perform better. Every window alarm wakes you earlier than the set time on average, so the app should include a minimum-sleep guard and be transparent about the trade-off. Phone apps detect stages poorly in PSG comparisons; no phone app detected REM.

**What we can build (v1 rule, from appendix 04 §6).** Window = the 30 minutes before the alarm time (10 to 30 configurable; longer only in a future phone-mic mode). Every 30 seconds inside the window, score the epoch from accelerometer activity counts (Cole-Kripke) and heart rate relative to the night's baseline. Fire when: awake for 2 minutes, or two consecutive light/REM epochs, or the window ends. If the signal is missing for 3 minutes, fire at the end. Snooze converts to a plain alarm. Everything is on-device.

**Why the Watch has to be armed nightly.** Apple's Developer Technical Support confirmed in 2025 that there is no way to schedule an extended runtime session without user interaction, and the Watch app must be in the foreground to call `start(at:)`. The app can make this nearly painless: a bedtime notification on the wrist that deep-links into the app, one tap to arm, and a complication that shows "armed for 06:30 to 07:00". A shipped App Store precedent (WakeTF, MIT) does exactly this.

---

## 5. Recommended architecture

```
┌──────────────── iPhone (SwiftUI, iOS 26+) ────────────────┐
│ Data:      SwiftData store  ◄── HealthKit importer (sleep)  │
│ Models:    SleepNeed, SleepDebt, CircadianSchedule, Habits  │
│ Alarm:     AlarmKit (fixed alarm at window END, safety net) │
│            widget extension for the AlarmKit Live Activity  │
│ UI:        Home / Progress / Energy / Tools / Guidance      │
│ Bridge:    WatchConnectivity (plan down, "wake now" up)     │
└──────────────────────────┬─────────────────────────────────┘
                           │ WCSession
┌──────────────── Apple Watch (watchOS 26+) ─────────────────┐
│ WKBackgroundModes: [alarm]                                  │
│ Bedtime: user taps "Arm" → session.start(at: windowStart)   │
│          CMSensorRecorder 12h (pre-window context)          │
│ Window:  handle(session) → CMMotionManager 25-50 Hz         │
│          30-s epochs: activity counts + passive HR          │
│          rule fires → notifyUser(haptic) + sendMessage(wake)│
│ Morning: optional own sleepAnalysis samples to HealthKit    │
└────────────────────────────────────────────────────────────┘
```

Key decisions baked into this:

- **Watch is the primary alarm; phone is the fallback.** If the watch message never reaches the phone, the user gets an early haptic and the phone rings at window end. Double alarm beats no alarm.
- **Never move an AlarmKit alarm; cancel and schedule.** Prefer `.relative` schedules for the repeating alarm because of an iOS 26.1 to 26.5 bug where `.fixed` alarms sometimes fire at midnight, and use `.fixed` only for the computed early fire.
- **No workout session for heart rate.** Frequent HR needs a workout session, which fills Activity rings and drains battery. Use accelerometer as the main signal (Apple's own stager is accelerometer-only) and passive HR as a weak feature.
- **Keep the in-window model cheap.** Sustained CPU inside an extended runtime session gets it cancelled.
- **Pure-Swift domain package** (`DawnCore`: debt, schedule, habits, alarm rule, actigraphy) with no UI or platform imports, so it is unit-testable on macOS and shared by phone, watch and widgets. JetLagBuster (MIT) shows this pattern at ~600 lines.

Project shape, matching the sibling `markdown-app` conventions: plain Xcode project, Swift 6 strict concurrency, `App/ Models/ Views/ Services/ Resources/` per target, a `Makefile` with build/test/install, `.xcconfig.template` for `DEVELOPMENT_TEAM` and bundle prefix, unsigned CI builds.

---

## 6. Algorithms for v1 (summary; equations in appendix 04)

| Piece | Approach | Source to port (licence) |
|---|---|---|
| Sleep need | Seed 8h15; median of last 10 alarm-free nights, EMA α=0.1; clamp 5 to 11.5h; manual override | Rise's public description; Kitamura 2016 |
| Sleep debt | Σ over 14 nights of (need − slept incl. naps) with weights 0.15·0.872ⁱ; floor at 0; bands <5h / 5-10h / >10h | Rise calculator; shafakatr/SleepDebt (MIT) |
| Energy Potential | clamp(100 − 2.1·debt, 20, 100) as a first guess; tune | SAFTE reservoir scaling |
| Energy curve | Three-process model A = S + C + U + W with published constants, normalised to 0-100, scaled by Energy Potential | Ingre 2014 (open); Arcascope `circadian` (MIT) for a later ODE upgrade |
| Phase anchors | DLMO = habitual bedtime − 2h; CBTmin = DLMO + 7h; Melatonin Window = DLMO + 1.05h to + 2.05h; peaks/troughs from the curve with offset priors | Burgess & Fogg; Rise's own published formula |
| Habit offsets | Caffeine MW − 10h; melatonin supplement B − 6.5h (advance) or B − 45 min (aid); light W to W+1h; dim lights B − 2h; vigorous exercise B − 1.5h; big meal B − 3h; alcohol B − 3h; wind-down B − 1.5h; nap only in afternoon dip | Gardiner 2023, Burgess PRC, Stutz 2019, Rise blog |
| Sleep/wake from motion | Cole-Kripke on 1-min activity counts + Webster rescoring; van Hees z-angle for the sleep window | actigraph/Sleep-Wake-Classification (MIT), GGIR (Apache-2) |
| Light-vs-deep in window | Activity magnitude + variability thresholds on 30-s epochs, HR vs night baseline, 2-epoch confirmation | Re-derive (Somn is GPL); WakeTF `WakeScorer` (MIT) |
| Later: 4-class staging | Train on PhysioNet sleep-accel (ODC-By) via ojwalch/sleep_classifiers (MIT) → CoreML; or convert SLAMSS-IFS (BSD-3) | Both open |
| Sleep quality | 35 duration + 20 efficiency + 15 latency + 15 WASO + 15 self-rating/stages; NSF thresholds; Fitbit-style bands | Ohayon 2017 |
| Smart Schedule | Forward-simulate the debt model with recommended bed/wake until the band flips | Own |

---

## 7. Prior art worth reusing (details in appendix 05)

- **acwo/waketfapp** (MIT, Swift, watchOS 11+): the whole watch smart-alarm skeleton, session lifecycle, motion + HR monitors, a documented `WakeScorer`, XCTests. Highest-value reuse.
- **AlarmKit samples**: ADHDAlarms (MIT), AlarmKitDemo (MIT), Alare (MIT, shipped, escalation/re-snooze), SmartAlarm-iOS (MIT, pre-iOS-26 notification fallback if we ever support iOS 25).
- **SleepChartKit** (MIT, 246 stars): Canvas hypnogram + circular hours-vs-goal chart, takes `HKCategorySample` directly. Rise's vertical stage rail is a rotated version of this.
- **Yotei / CleanCocoa timeline-ui** (MIT): day-timeline layouts for the 24-hour Energy tab.
- **Native SwiftUI `Gauge`** for the debt ring.
- **Arcascope `circadian`** (MIT, Python) and **PabRod/sleepR** (MIT, R): reference implementations of the two-process and Forger/Hannay models for porting.
- **JetLagBuster `JetLagCore`** (MIT): pure-Swift circadian scaffolding with App Group sharing to the watch.
- **SpeziHealthKit** (MIT) if we want a full HealthKit module; otherwise a ~200-line in-house wrapper.
- Audio: `AVAudioPlayer.setVolume(_:fadeDuration:)` for in-app ramps (AlarmKit's own alert audio is system-rendered, so gentle-wake on the phone alarm is limited to the < 30 s bundled sound); CC0 alarm sounds from Freesound/Pixabay.
- Read-only references (GPL): Somn's threshold heuristics, pyActigraphy's algorithm docs, OpenRing's hypnogram scrubber, SAFTEr.

---

## 8. Licensing and repo conventions

- **Recommend Apache-2.0 with a DCO.** Everything worth linking is MIT/BSD/Apache; Apache adds a patent grant (SAFTE was patented, Sleep Cycle holds sound-analysis patents) and has no App Store friction for forks. Keep the app name and icon out of the grant.
- Alternative if blocking proprietary App Store forks matters more: GPL-3 with a Nextcloud-style §7 App Store exception and a CLA.
- Add an `ATTRIBUTIONS` file for the ODC-By dataset and any CC-BY sounds.
- Repo pattern (NetNewsWire / Ice Cubes / Home Assistant): `.xcconfig.template` for team and bundle prefix, unsigned CI builds on GitHub Actions, TestFlight via Xcode Cloud or fastlane match, a short release checklist.

---

## 9. Risks and open questions

Verified constraints that shape the plan:

- Wake window capped at **30 minutes** on the Watch; longer windows only in a future phone-mic mode.
- Watch must be **armed from the foreground each night**; no unattended scheduling exists.
- AlarmKit: no update API, no app code at fire time, a documented-but-unquantified alarm count limit, and a midnight-fire bug on `.fixed` schedules in 26.1 to 26.5.
- Apple Watch stages reach HealthKit **after** wake; exact latency unpublished.
- Frequent HR on the Watch requires a workout session; passive HR is sparse.

Unconfirmed items to settle with small spikes before or during planning:

1. AlarmKit minimum lead time for a fresh `.fixed` alarm (community says ~60 s) and whether scheduling with an existing id replaces in place.
2. Whether `WCSession.isReachable` is true from inside a smart-alarm extended runtime session (docs only cite workout sessions). Determines whether the phone can be cancelled reliably.
3. Whether `CMSensorRecorder` returns samples while watchOS's own sleep tracking is active (one blog says no).
4. How much passive HR actually arrives inside a 30-minute session without a workout.
5. Rise's exact debt weights, Energy Potential mapping, and band labels; only needed if we want to match its numbers rather than define our own.
6. Whether `sleepAnalysis` background delivery is throttled to hourly on iOS.

Product risks:

- **Overclaiming.** Say "wakes you in lighter sleep when it can", not "optimal".
- **Nightly arming friction** is the feature's Achilles heel; the bedtime notification and complication must make it one tap.
- **Phone-only users** get a plain alarm plus tappigraphy-based sleep detection in v1; be explicit in onboarding.
- **App Review**: stay inside AlarmKit and the `alarm` background mode; do not ship mattress-mode copy that suggests charging under a pillow.

---

## 10. Suggested shape for the planning phase

A proposal, not a plan yet.

- **Spike 0 (days):** a throwaway iPhone + Watch project that arms a smart-alarm session, logs accelerometer and HR inside it, fires a haptic, and cancels an AlarmKit alarm on the phone. Answers open questions 1 to 4 and proves the whole chain on real hardware.
- **v0.1:** `DawnCore` package with sleep need, debt, three-process schedule, habit offsets, Cole-Kripke, alarm rule; full unit tests with fixture nights. HealthKit importer. Home + Progress + Energy screens reading real data.
- **v0.2:** AlarmKit alarms with days, gentle wake, debt warning, wake-window guidance; Watch app with nightly arming and the in-window rule; widgets + complication.
- **v0.3:** Manual/nap editing and awake-splitting, quality rating and score, Smart Schedule projection, Calendar export, data export, onboarding polish, TestFlight.
- **Later:** phone-mic mode, CoreML 4-class staging, light-driven phase model, sounds and relaxation content.

---

## 11. Decisions needed before planning

*Update 2026-09-30: items 1, 2, 6 and 7 are decided (iOS 26 / watchOS 26; watch-first alarm; "Dawn: Smart Alarm"; Apple Watch SE 2 on 26.6). Item 3 (licence), 4 (own numbers) and 5 (SwiftData) follow the recommendations unless overridden. See `01-architecture-direction.md` §5.*

1. **Minimum OS**: iOS 26 / watchOS 26 (unlocks AlarmKit and current session APIs; drops iOS 25 users). Recommended yes.
2. **Watch-first for the smart alarm** and a plain AlarmKit alarm for phone-only users in v1, with phone-mic mode deferred. Recommended yes.
3. **Licence**: Apache-2.0 + DCO (recommended) or GPL-3 + App Store exception.
4. **Match Rise's numbers or define our own?** Its weights and mappings are unpublished; recommended: define our own, document them, keep them user-visible.
5. **Persistence**: SwiftData (simplest, iOS 26-native) vs GRDB (SQL, export-friendly). Recommended SwiftData with a JSON export.
6. **Name and bundle identifier** for the project (working name "Dawn", directory `dawn-app`).
7. **Hardware**: which Apple Watch model(s) you can test on; Series 6+ is what WakeTF requires.

---

## Environment check (this Mac, 2026-09-30)

| Item | Value |
|---|---|
| Xcode | 27.0 (27A266a) |
| SDKs | iOS 27.0, iOS Simulator 27.0, watchOS 27.0, watchOS Simulator 27.0 |
| Swift | 6.4 |
| Simulator runtimes | none listed by `simctl` yet; install from Xcode > Settings > Components |
| Sibling project conventions | `markdown-app`: plain `.xcodeproj`, Swift 6, deployment target 26, `App/Models/Views/Services/Resources`, `Makefile`, `.scratch/` gitignored |

Memory store: platform constraints and the Rise help-center retrieval trick are recorded under `personal/dawn-app/` in the deep-thought store (committed, not pushed).
