# Prior art (agent survey, 2026-09-30) — condensed

## Takeaways
1. No OSS iOS app does the whole Rise loop. Closest: acwo/waketfapp (MIT, Swift, watchOS smart alarm on WKExtendedRuntimeSession .smartAlarm; WakeScorer motion 0.75/HR 0.25, median+MAD baseline, 60s warm-up; AlarmScheduleCalculator; XCTests; ARCHITECTURE.md). watchOS 11+, Series 6+.
2. Alarm mechanism settled by Apple: iOS 26 AlarmKit (fires locked/app killed; MIT samples: ADHDAlarms, AlarmKitDemo, Alare (shipped, escalation), Cizzuk) + watchOS .smartAlarm extended runtime session (schedule <=36h ahead, <=30 min runtime, must play >=1 haptic or system may disable future sessions, app launched at start time, HR via HealthKit queries). Pre-iOS-26 hacks (silent audio loop gdelataillade/alarm; .timeSensitive notifications SmartAlarm-iOS w/ NotificationBudget for 64-pending limit) documented unreliable by authors.
3. Stage algorithms all Python/R. Port from: ojwalch/sleep_classifiers (MIT, Apple Watch, PhysioNet sleep-accel ODC-By 1.0, 31 subjects PSG), BIDSLabUMass/SLAMSS-IFS (BSD-3, 4-class LSTM IHR+accel, 71% acc, 30s epochs), actigraph/Sleep-Wake-Classification (MIT; Sadeh, Cole-Kripke, van Hees SIB angle_thres=5 time_thres=5min), GGIR vanHees2015 (Apache-2). No CoreML sleep-staging model exists on GitHub -> coremltools from sklearn/PyTorch or Create ML tabular.
4. Circadian/debt math MIT: Arcascope/circadian (Forger99, Hannay19 [3 ODEs], Jewett99, TwoProcessModel a=0.10 RK4, sleep_midpoint, DLMO metrics), PabRod/sleepR (Borbely ~40 lines: H decays H0*exp(-t/chi_s) asleep, rises mu+(H0-mu)*exp(-t/chi_w) awake; switch when H crosses Hu0/Hl0 + a*sin(wt-alpha)). shafakatr/SleepDebt (MIT JS): debt = sum max(0, need - asleep) over 14 nights; need = mean of longest 20% nights clamped 6.5-9.5h; energy curve smoothstep 14 control points after wake flattened by debt; sessions <2.5h = naps; night grouping gap <=3h. Rise says: 14-night recency-weighted debt, last night ~15%, other 85% over prior 13; need estimated from ~year of phone data (default 8.25h; median 8h, range 5-11.5); <5h debt = target; energy schedule from SAFTE-derived model + recent sleep + inferred light. SAFTEr (GPL-3 R) only open SAFTE.
5. License: ecosystem MIT/BSD/Apache. Recommend Apache-2.0 + DCO (patent grant; SAFTE patented, Sleep Cycle sound patents). Alt: GPL-3 + Nextcloud COPYING.iOS s7 exception + CLA. Keep name/icon out of grant. ATTRIBUTIONS file for ODC-By / CC-BY.

## Android references
- Vic-41148/somn (GPL-3 Kotlin): ClassifySleepStageUseCase: 30s epochs ~10Hz, RMS(acc-g)+stddev; AWAKE>=0.15, DEEP<=0.05&var<=0.03, REM mag<=0.10&var 0.02-0.08, else LIGHT; 3-epoch mode smoothing. SmartAlarmUseCase: ring at target or in window when LIGHT/AWAKE. Re-derive, don't copy.
- seeingred/aka-alarm (MIT): mic baseline spike in 30-min window, 60s fade-in, motion-triggered snooze.
- Sleep as Android docs: ACT-phases (low activity -> deep, higher -> light; REM candidates by hypnogram position), smart wake in window during light phase, claims 96% not ringing in N3.
- Sleep Cycle: patented mic sound analysis + accelerometer. Pillow: motion+mic. Sleep++: HR+calories+steps. Apple Watch native staging: accelerometer-only, 30s epochs (Apple paper Oct 2025 PDF).

## UI
- DanielJamesTronca/SleepChartKit (MIT, 246 stars): Canvas hypnogram + circular hours-vs-goal, takes [HKCategorySample].
- claustrofob/Yotei (MIT, 143 stars) day timeline; CleanCocoa/timeline-ui (MIT) DayTimelineView hour grid.
- Native SwiftUI Gauge (.accessoryCircular) for debt ring. jordibruin/Swift-Charts-Examples (no sleep example).
- eladkishon/jetlagbuster (MIT): JetLagCore pure Swift ~600 LOC: CBTmin = wake - 3h, Burgess 2011 light windows, melatonin timing, XCTest, App Group sharing to watch.
- jakublipinski/Silent-Bell (Apache-2): watchOS background haptics via .physicalTherapy; every WKHapticType except .click plays sound when Silent Mode off.
- StanfordSpezi/SpeziHealthKit (MIT): CollectSamples continueInBackground; heavy. kvs-coder/HealthKitReporter (MIT) Codable HK export.

## Audio
- AVAudioPlayer.setVolume(_:fadeDuration:); Cephalopod (MIT) fade curves. AlarmKit alert audio is system-rendered: in-app ramps do NOT apply to AlarmKit alert (flag). Sounds: Freesound CC0 packs, Pixabay CC0, Mixkit (own licence).

## Repo/CI patterns
- xcconfig.template for DEVELOPMENT_TEAM/BUNDLE_ID_PREFIX (Ice Cubes), unsigned CI builds (NetNewsWire, Mullvad CODE_SIGNING_ALLOWED=NO on macos-26), secrets via templates/env, TestFlight via Xcode Cloud (simplest) or fastlane match + GH Secrets (Home Assistant), Technotes release checklist.

## Unconfirmed flags
AlarmKit custom-sound API & ramps; SLAMSS-IFS CoreML convertibility; bidsleep dataset licence; Somn on F-Droid; ADHDAlarms licence; Apple sleep-stage PDF details secondhand; SAFTE patent status.
