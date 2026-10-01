# Sleep-science and algorithm research (agent report, 2026-09-30)

Legend: [VERIFIED] = read from the cited page; [UNCONFIRMED] = from search snippets / recall.

## 1. Sleep debt

### 1.1 What Rise publishes
- Definition: sleep debt = sum over last 14 nights of (sleep need - sleep obtained). Surplus nights reduce the total; net-positive clamps to 0. [VERIFIED] https://www.risescience.com/blog/sleep-debt-calculator
- Recency weighting: "Last night carries about 15% of the weight. The previous 13 nights carry the rest, with recent nights counting more." Per-night weights not published. [VERIFIED] https://www.risescience.com/blog/rise-app-review
- Sleep need: estimated from "a year of phone-use behavior and sleep-science algorithms" (proprietary; not user-settable). Calculator default 8h15. Population (1.95M users 24+): 5h - 11h30, median 8h. [VERIFIED]
- Naps: logged manually, count toward paying down debt. [UNCONFIRMED] https://www.risescience.com/blog/how-much-sleep-debt-do-i-have
- Thresholds: <5h = "the range RISE aims for"; 5-10h = "enough to feel"; >10h = "a lot to carry"; 0 = ideal. [VERIFIED]
- "Okay / Great / Super" labels NOT FOUND on Rise's site. In-app strings; unconfirmed thresholds.
- Energy Potential (0-100): "tied directly to sleep debt, not to estimated stages"; formula unpublished. [VERIFIED]

### 1.2 Literature
- Sleep need under extended opportunity: young adults 8.5 +/- 1.0h; older ~7.4-8.1h (Klerman & Dijk 2008) https://pmc.ncbi.nlm.nih.gov/articles/PMC2582347
- Kitamura 2016: optimal ~8.16h in 21-38yo; 1h/night debt takes ~4 days to normalise, up to 9 days. https://www.nature.com/articles/srep35812
- Van Dongen 2003: 14 days at 4h/6h TIB => cumulative deficits; PVT lapses near-linear in cumulative wake beyond 15.84h/day (=> 8.16h zero-debt point). https://academic.oup.com/sleep/article-abstract/26/2/117/2709164
- Banks 2010: recovery gradual, one 10h night does not fully restore. https://pmc.ncbi.nlm.nih.gov/articles/PMC2910531/
- Recovery review: https://pmc.ncbi.nlm.nih.gov/articles/PMC10108639

### 1.3 Concrete v1 algorithm
```
NEED0 = 8.25 h ; clamp need to [5.0, 11.5]
need estimation:
  - seed with NEED0 (or age band)
  - "free" nights = no alarm fired AND wake not forced, or weekends/holidays
  - need = EMA(alpha=0.1) of median(duration of last 10 free nights); update only when >= 3 free nights
  - manual override; slow drift only (max +/-10 min/week)

per-night balance b_i = sleep_i(main + naps) - need   (i = 0 last night ... 13)
Option A (Rise public calculator): debt = max(0, -sum_{i=0..13} b_i)
Option B (Rise recency weighting; exact form UNCONFIRMED):
  w_i = 0.15 * r^i, r ~ 0.872 (sum w_i = 1 over 14 nights; w = .150,.131,.114,.100,.087,.076,.066,.058,.050,.044,.038,.033,.029,.025)
  debt = max(0, -14 * sum w_i * b_i)
labels: <5h on track ; 5-10h noticeable ; >10h high
energy potential (SAFTE-derived guess): EP = clamp(100 - 2.1 * debt, 20, 100)
```
Naps: add to day's sleep before b_i; cap single nap credit at ~90 min (suggestion).

## 2. Circadian energy schedule

### 2.1 Two-process model (Borbely 1982; Daan/Beersma/Borbely 1984) [VERIFIED] https://www.biorxiv.org/content/10.1101/2025.01.22.634299v2.full.pdf ; https://www.nature.com/articles/s44323-025-00039-z
```
wake:  dS/dt = (mu - S)/chi_w  ->  S(t) = mu - (mu - S0) exp(-t/chi_w)
sleep: dS/dt = -S/chi_s        ->  S(t) = S0 exp(-t/chi_s)
H+(t) = H0+ + a C(t) ; H-(t) = H0- + a C(t) ; C(t) = cos(2 pi (t - phi)/24)
chi_s = 4.2h, chi_w = 18.2h, H0+ = 0.67 (0.6 some papers), H0- = 0.17, a = 0.12, mu = 1
natural: T_sleep = chi_s ln(H0+/H0-) = 5.8h ; T_wake = chi_w ln((mu-H0-)/(mu-H0+)) = 16.8h
```
Skewed C(t) harmonics (0.97, 0.22, 0.07, 0.03, 0.001; Achermann & Borbely 1994) [UNCONFIRMED].

### 2.2 Three-process model of alertness (Akerstedt & Folkard; Ingre 2014) [VERIFIED] https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0108679
```
S (wake):  S(t) = la + (S_wake - la) exp(-d t)     ha = 14.3, la = 2.4, d = 0.0353 /h, t = h since wake
S' (sleep): S'(t) = ha - (ha - S_sleep) exp(-g t)  g = 0.381 /h (brake above bl = 12.2)
C(t) = Cm + Ca cos(2 pi (t - p)/24)                Ca = 2.5, Cm = 0, p = 16.8 (peak ~16:48)
U(t) = Um + Ua cos(2 pi (t - p)/12)                Ua = 0.5, Um = -0.5
W(t) = Wc exp(Wd t)                                Wc = -5.72, Wd = -1.51 /h (sleep inertia, t since wake)
A = S + C + U + W ; KSS = 10.6 - 0.6 A (Ingre: 9.68 - 0.46 A)
Scale: 14 high alertness, 7 sleepiness threshold, 3 extreme sleepiness
```

### 2.3 SAFTE (Hursh 2004) — the model Rise says it builds on [VERIFIED equations via Frontiers 2022] https://www.frontiersin.org/journals/public-health/articles/10.3389/fpubh.2022.996664/full
```
Rc = 2880 units; wake depletion K = 0.5 units/min (~30/h)
R_t = R_{t-1} + S - P
c(t) = cos(2 pi (t - p)/24) + beta cos(4 pi (t - p')/24)   p = 18h, beta = 0.5, p' = p + 3 (=21h) [p' UNCONFIRMED]
E(t) = 100 (R_t/Rc) + c(t) (a1 + a2 (Rc - R_t)/Rc) - I(t)   a1 ~ 7, a2 ~ 5 (or 0.07/0.05), I = inertia decaying after wake
```

### 2.4 How Rise anchors the schedule [VERIFIED] https://www.risescience.com/blog/circadian-rhythm-test
- Inputs: inferred light exposure, recent sleep times; built on SAFTE.
- DLMO computed with St Hilaire (2007) light-driven model fed with inferred light + sleep times.
- Melatonin Window = DLMO + 1.55h +/- 30min (1-hour window).
- Phases: wake zone, grogginess (up to 90 min), morning peak, afternoon dip, evening peak, wind-down (1-2h before sleep, after evening peak, before MW), Melatonin Window. https://www.risescience.com/blog/biological-clock ; https://www.risescience.com/blog/wind-down-time
- Not anchored on sleep midpoint per se; daily-updated light/sleep-history phase estimate.

### 2.5 Phase anchors from literature
- DLMO ~ 2h before habitual bedtime (Burgess & Fogg); DLMO correlates with wake r=0.70; midpoint ~ DLMO + 6h+; offset ~ DLMO + 10h. https://pmc.ncbi.nlm.nih.gov/articles/PMC12320674/
- CBTmin ~ DLMO + 7h ~ 2-3h before habitual wake. https://pmc.ncbi.nlm.nih.gov/articles/PMC2914120/
- Wake-maintenance zone (Lavie 1986) = 2-3h before habitual bedtime -> evening peak. https://www.nature.com/articles/s41598-018-29380-z
- Sleep inertia: main effects <= 30 min, subjective up to ~2h; W time constant ~40 min. https://www.dovepress.com/sleep-inertia-current-insights-peer-reviewed-fulltext-article-NSS

### 2.6 Simplified on-device algorithm (v1)
```
inputs: recent main-sleep intervals (7 days), last wake W_last, habitual bed B_hab / wake W_hab (7-day circular median; last 3 nights x2)
phase:
  DLMO = B_hab - 2.0h ; CBTmin = DLMO + 7.0h ; phi (circadian peak) = CBTmin + 12h (~16:48 for 23-07 sleeper)
  upgrade: St Hilaire/Forger light-driven model using screen-on/steps as light proxy
energy curve: A(t) = S + C + U + W (2.2) with actual last wake and sleep length
  energy% = 100 (A - 3)/(14.3 - 3) clamped 0-100, scaled by EP/100
phases (heuristic priors; Rise exact rules unpublished):
  grogginess:      W_last -> W_last + 60-90 min (end when W(t) > -0.5)
  morning peak:    end grogginess -> W_last + 5.5h (local max A)
  afternoon dip:   W_last + 6.5h -> W_last + 9h (local min; ~13:30-16:00)
  evening peak:    W_last + 9.5h -> DLMO (wake-maintenance zone)
  wind-down:       max(DLMO, B_hab - 1.5h) -> B_hab
  melatonin window:[DLMO + 1.05h, DLMO + 2.05h]
  wake zone:       [W_hab - 30min, W_hab + 30min]
impl: A(t) on 5-min grid; peaks/troughs via sign change of dA/dt, 45-min min separation; label with offsets as priors when flat.
```

## 3. Habit windows (offsets from bedtime B / wake W)
| Habit | Evidence | v1 rule |
|---|---|---|
| Caffeine cutoff | Gardiner 2023 meta: coffee (107mg) >= 8.8h before bed; 217mg >= 13.2h; Drake 2013: 400mg at 0/3/6h cut TST ~1.2h. Rise reminds 10h before Melatonin Window (~12h before bed). https://www.sciencedirect.com/science/article/pii/S1087079223000205 ; https://www.risescience.com/blog/how-long-does-caffeine-last | last caffeine = MW_start - 10h (~B - 11h); dose-aware >=9h one coffee, >=13h for >=200mg |
| Melatonin supplement | Burgess PRC: to advance take 0.5-3mg ~4-5h before DLMO (~B - 6..7h); at bedtime barely shifts. Rise: "4-5h before bed to sleep earlier; 30-60 min before bed otherwise". https://pmc.ncbi.nlm.nih.gov/articles/PMC2928905/ | advance: B - 6.5h (0.5mg); aid: B - 45min |
| Light | Light PRC: after CBTmin advances, before delays. 2h of 2500 lux before bed suppresses melatonin. https://pmc.ncbi.nlm.nih.gov/articles/PMC3406389/ | outdoor light W -> W+1h (>=30 min); dim lights from B - 2h; avoid bright B-3h -> B |
| Exercise | Stutz 2019 meta: evening exercise neutral/positive; vigorous ending <=1h before bed may impair. https://link.springer.com/article/10.1007/s40279-018-1015-0 | vigorous cutoff B - 1.5h; moderate B - 0.5h |
| Meals | last meal within 3h of bed -> more awakenings. https://www.ncbi.nlm.nih.gov/pmc/articles/PMC7215804/ | large meal cutoff B - 3h |
| Naps | Rise: during afternoon dip, 10-20 min. https://www.risescience.com/blog/best-nap-length | nap window = afternoon dip; block after B - 8h |
| Wind-down | Rise: 1-2h before planned sleep. https://www.risescience.com/blog/wind-down-time | start B - 1.5h |
| Alcohol | common guidance 3-4h [UNCONFIRMED] | B - 3h |

## 4. Stages, cycles, inertia, smart-alarm evidence
- Cycle ~90-110 min. Young adult: N1 ~5%, N2 ~50%, N3 20-25%, REM 20-25%; N3 early, REM later. https://www.ncbi.nlm.nih.gov/sites/books/NBK526132/
- Inertia (Hilditch & McHill 2019): worst from N3 (41% perf drop vs none from N2); strongest first 30 min; worse after restriction and at circadian trough. Mixed: some studies find no stage association once prior wake controlled. https://www.dovepress.com/sleep-inertia-current-insights-peer-reviewed-fulltext-article-NSS
- Smart alarm effectiveness (honest): mechanism plausible; consumer devices detect light-vs-deep moderately (kappa 0.4-0.68). Only RCT-style test: Campanella 2024 — lower perceived inertia, NO significant PVT improvement. https://www.ncbi.nlm.nih.gov/pmc/articles/PMC10969141/ Phone apps: Fino 2020 PSG study of 4 apps (n=21): Sleep Cycle unreliable for sleep/wake, overestimated deep, no app detected REM. https://pubmed.ncbi.nlm.nih.gov/31674096 Caveat: window alarms wake you earlier on average -> min-sleep guard.

## 5. Stage detection without EEG

### 5a. Actigraphy (1-min epochs)
- Cole-Kripke (1992): D = 0.001 (106 A-4 + 54 A-3 + 58 A-2 + 76 A-1 + 230 A0 + 74 A+1 + 67 A+2); sleep if D < 1. 88-91% agreement. https://rdrr.io/github/dipetkov/actigraph.sleepr/man/apply_cole_kripke.html
- Sadeh (1994): PS = 7.601 - 0.065 AVG - 1.08 NATS - 0.056 SD - 0.703 LG over 11-min window; sleep if PS >= 0. https://www.mdpi.com/1424-8220/21/18/6313
- Oakley/Actiwatch: O = A-2/25 + A-1/5 + A0 + A+1/5 + A+2/25; wake if O > 40 (medium). https://ghammad.github.io/pyActigraphy/_autosummary/pyActigraphy.sleep.ScoringMixin.Oakley.html
- Webster rescoring (1982): after >= a min wake, rescore next b min wake, (a,b) in {(4,1),(10,3),(15,4)}; sleep bout <= c min surrounded by >= d min wake -> wake, (c,d) in {(6,10),(10,20)}. https://arxiv.org/abs/2104.14291
- Tudor-Locke onset/offset: onset = first of 5 consecutive sleep min; offset = first of 10 consecutive wake min; valid >= 160 min.
- van Hees HDCZA (GGIR 2018): 5-s means -> z-angle = atan(az/sqrt(ax^2+ay^2)) deg -> |delta angle| -> 5-min rolling median -> threshold = 15 x 10th percentile -> blocks below threshold >= 30 min; merge gaps < 60 min; longest block noon-noon = SPT. Inside SPT: angle change < 5 deg for >= 5 min = sleep (van Hees 2015). (Check 30/60 constants.) https://onlinelibrary.wiley.com/doi/10.1111/jsr.13760

### 5b. HR / accel models
- Walch 2019 (Apple Watch, n=31 PSG): 30-s epochs, 10-min feature window; activity counts (te Lindert) Gaussian sigma=50s; HR interpolated 1s, DoG filter (120s, 600s), normalised by 90th pct; clock proxy = Forger model driven by steps. Sleep/wake 80.1% acc, kappa 0.32, AUC 0.88; wake/NREM/REM 72.3%, kappa 0.28. HR alone poor for wake; clock proxy +14%. https://academic.oup.com/sleep/article/42/12/zsz180/5549536
- Apple classifier (Oct 2025 PDF) [VERIFIED]: accelerometer only (respiration micro-motion), 30-s epochs, Awake/Core/Deep/REM; trained 1171 nights/858 subjects; sleep sens 97.9%, spec 75.0%, 4-stage kappa 0.63 (updated: 96.8/78.9, wake acc 79%, kappa 0.68). Available via HealthKit after the night, not live. https://www.apple.com/health/pdf/Estimating_Sleep_Stages_from_Apple_Watch_Oct_2025.pdf
- sleep-accel-dl (MIT; CNN+BiLSTM): 4-class kappa 0.35 accel+HR, 0.10 accel-only -> HR separates stages at low rates. https://github.com/ameyypawar/sleep-accel-dl
- SleepPPG-Net: raw PPG kappa 0.676 but Watch does not expose raw PPG. https://pubmed.ncbi.nlm.nih.gov/36446010/

### 5c. Phone-on-mattress
- Sleep Cycle: accelerometer + patented mic analysis; Fino 2020 unreliable for stages.
- Sleep as Android: actigraphy or sonar (18-20 kHz) detecting chest movement/breath rate. https://sleep.urbandroid.org/introducing-sonar-as-sensor/

### 5d. Sound-based: mel-spectrogram DL 4-class ~70%; deep-vs-light weak. https://www.jmir.org/2023/1/e46216

### 5e. Recommended pipeline
- Watch next-morning: read HealthKit stages (kappa ~0.63-0.68); do not re-derive. Fallback: Cole-Kripke + Webster on CMSensorRecorder counts.
- Watch live (smart alarm): WKExtendedRuntimeSession Smart Alarm type [VERIFIED] https://developer.apple.com/documentation/watchkit/using-extended-runtime-sessions : schedulable <= 36h ahead via start(at:), 30-min hard limit, "monitor HR and motion", must call notifyUser(hapticType:repeatHandler:). Window capped at 30 min. Inside: 30-s epochs Cole-Kripke counts + HR vs night baseline; require >= 2 consecutive positive epochs.
- Phone-only: mattress accel 50-100 Hz -> 30-s counts -> Cole-Kripke/Webster; light proxy = movement density above night median; if no variance (phone off bed) fire at window end. No REM, deep overestimated.

## 6. Smart-alarm decision logic
Vendors: Sleep Cycle window 10-30 min (default 30). Sleep as Android 5 min - 2h (default 30), rings exactly at set time if none detected, fade-in, backup full-volume after 20 min. Fitbit Smart Wake 30 min, light only, else set time. Pixel Watch 30 min HR+movement; already awake -> standard alarm; snoozed -> standard. Garmin 30 min, always at selected time at latest.
```
window = [T_end - L, T_end], L default 30 min (10-30 Watch; up to 60 phone-only)
guard: T_start >= sleep_onset + max(4h, need - 1.5h) else shrink window
per 30-s epoch: activity_e, hr_e ; baseline = night median HR, MAD
awake(e) := CK D >= 1 for >= 3 of last 4 epochs OR (activity spike AND hr > baseline + 2 MAD)
light(e) := D in [0.3,1) current+previous OR hr > baseline + 1 MAD with mild motion (REM treated as OK-to-wake)
deep(e)  := D < 0.1 for >= 4 epochs AND hr <= baseline
loop every 30s in window:
  awake >= 2 min -> fire now
  light 2 consecutive epochs -> fire
  signal missing > 3 min -> fire at T_end
  optional prior: boost light score if (t - onset) mod 90 in [75,95] min
t == T_end -> fire unconditionally
snooze 5-9 min -> plain alarm; backup at T_end + 20 min if never dismissed
```

## 7. Sleep quality scoring
- NSF consensus (Ohayon 2017): efficiency > 85%, latency <= 30 min, <= 1 awakening > 5 min, WASO <= 20 min.
- PSQI > 5 poor. Single-item SQS 0-10, <= 6 poor.
- Fitbit bands 90-100 excellent, 80-89 good, 60-79 fair, < 60 poor. Oura: 85-100 optimal / 70-84 good / 60-69 fair.
- v1 score: 35 min(1, TST/need) + 20 clamp((eff-70)/25) + 15 clamp(1 - max(0, SOL-15)/45) + 15 clamp(1 - max(0, WASO-10)/50) + 15 (SQS/10 if rated else 0.5 clamp(deep%/0.2) + 0.5 clamp(REM%/0.2)).

## Unconfirmed
Rise per-night weights, need estimator, EP formula, Okay/Great/Super; SAFTE p' and a1/a2 units; two-process skew coefficients; CK 30-s weights; Oakley 20/80; HDCZA 30/60 constants; 2025 caffeine RCT; alcohol evidence; HR sample frequency inside a smart-alarm session without a workout session.
