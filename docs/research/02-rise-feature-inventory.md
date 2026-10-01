# Rise (Rise Science) feature inventory

Research date: 2026-09-30. App: "RISE: Sleep Tracker" (App Store id 1453884781, v1.633.0, iOS 15.1+, watchOS 9.1+, visionOS 1.0+; Android `com.risesci.nyx`). Developer: Rise Science Inc.

Sources: Rise help center (77 articles via the open Zendesk API `https://help.risescience.com/api/v2/help_center/en-us/articles.json?per_page=100`; the HTML site is Cloudflare-gated), r/riseapp and the company account `u_Rise_Sleep_App` (via pullpush archive), App Store / Play listings, Rise's blog, Tom's Guide, Bustle, Mattress Clarity, Sleep Foundation, Yahoo, TapSmart, Trustpilot. A raw dump of the help-center text lives in `.scratch/rise-help-center-dump.md` (gitignored, reference only). Items marked **unconfirmed** have no primary source.

## 1. Product shape and navigation
- Positioning: "the only sleep tracker that also measures your sleep debt and energy levels"; built on the two-process model; **deliberately no sleep score and no native sleep-stage tracking**. https://apps.apple.com/us/app/rise-sleep-tracker/id1453884781 ; https://www.risescience.com/faq
- Tabs after the Oct 2025 redesign: **Home, Progress, Energy, Tools, Guidance** (Learn was renamed Guidance; Home rebuilt), plus a **Profile** icon top-right. Matches the user's screenshots. https://www.reddit.com/r/riseapp/comments/1o6nrfe/
- **Home**: Energy Carousel (today's Energy Potential, upcoming phases, durations, "shifts in timing from yesterday"); last night's sleep with awake time and data source; **+ Nap**; **Zz Sleep Detection** (Nightstand vs Mattress); sleep debt; tips. https://help.risescience.com/hc/en-us/articles/40611116762647
- **Profile**: My sleep need (+/- adjust), Wake time goal (weekday + weekend ranges), Smart Alarm, Data Sources (drag-to-prioritise; optional Health Connect/Garmin/Fitbit), Calendars, Notifications, Membership, referral. https://help.risescience.com/hc/en-us/articles/40621964556567 ; https://help.risescience.com/hc/en-us/articles/40672627502871

## 2. Sleep need and sleep debt
### Sleep need
- Estimated from **up to 365 nights** by detecting **sleep rebound** (longer nights after short stretches); clamped to research bounds. Inputs: phone motion/activity + steps (required); wearable sleep, workouts, time in daylight via Health (optional). https://help.risescience.com/hc/en-us/articles/40621897428631
- Population (1.95M users 24+): 5h to 11h30, median 8h. Updates only on a clear signal; may stay flat for months; new users allow 1-2 weeks. Manual override in Profile takes effect immediately. Initial value from onboarding quiz + historic phone data. https://help.risescience.com/hc/en-us/articles/40622025935767
### Sleep debt
- Rolling **14-night** window, **recency-weighted** (last night ~15%, the other 13 nights share 85% with more recent weighted more; decay curve unpublished). Only estimated **asleep** time counts (awake subtracted). https://help.risescience.com/hc/en-us/articles/40621334445335 ; https://www.risescience.com/blog/how-much-sleep-debt-do-i-have
- **Naps** count like night sleep; not auto-detected from phone; manual logging recommended. https://help.risescience.com/hc/en-us/articles/40621805049495
- No reset button; nights age out; edits up to 14 days back recalculate. https://help.risescience.com/hc/en-us/articles/40621404441111
- Public calculator: debt = sum(need - slept) over 14 nights, recency-weighted, default need 8h15, net-positive resets to zero. https://www.risescience.com/blog/sleep-debt-calculator
### Display and thresholds
- One number, hours with one decimal. Guidance: keep **under 5h**; zero ideal. Calculator bands: <5h optimal; 5-10h moderate; >10h high. In-app labels "Okay / Great / Super" and their thresholds: **unconfirmed** (a reviewer mentions moving from "high" to "okay").

## 3. Energy schedule
### Phases (display order; also written to Calendar)
1. Wake + morning grogginess (~90 min sleep inertia)
2. Morning peak
3. Afternoon dip (nap window)
4. Evening peak
5. Wind-down (1-2h before bedtime)
6. Melatonin Window (~1h; ~2h after DLMO; ideal time to fall asleep)
7. Wake Zone (predicted natural wake window; shown on Smart Schedule)
https://help.risescience.com/hc/en-us/articles/6654243671191 ; https://www.risescience.com/blog/circadian-rhythm-test
- Reviewer's example: grogginess ~90 min after wake, morning peak 8:15-11:30, afternoon dip 13:37-15:41, evening peak 17:00-20:15, wind-down from ~20:34. https://www.bustle.com/wellness/rise-sleep-tracking-app-review
### Derivation
- "Biomathematical model" combining recent sleep data, inferred light exposure and activity; named models: **SAFTE** and the **St Hilaire core-body-temperature model**. Updates daily. https://help.risescience.com/hc/en-us/articles/40672503374871
- Anchor = **wake time goal** (weekday range + weekend range; no per-day values). Setting the Smart Alarm updates the wake time goal, which moves the Melatonin Window and schedule. https://help.risescience.com/hc/en-us/articles/40672627502871
- Bedtime recommendation = Melatonin Window (where the body has actually been falling asleep), NOT wake time minus need. Shift bedtime ~15 min/night and Rise follows. Recurring complaint: "need 9.5h but melatonin window is 2am, alarm at 6". https://www.reddit.com/r/riseapp/comments/1r7h5ne/
- High debt does not shift phase timing; it mutes peaks and deepens dips. Workouts show an "energy boost" in the current zone (iOS only, needs Health workout permissions). Travel: shifts ~1 day per hour of time-zone change. Night shifts: Melatonin Window unreliable. No chronotype label.
### Energy Potential and deltas
- **Energy Potential** 0-100, "directly tied to your sleep debt, not to estimated REM or deep sleep"; 100% at 0h debt; mapping unpublished. https://www.risescience.com/blog/rise-app-review
- Carousel "Xm shorter/longer" = each phase's duration/timing shift vs yesterday (**copy unconfirmed**).
- **Peaks & Dips alerts**: push before each peak/dip. **Calendar integration** (iOS): writes editable events for grogginess, peaks, dip, wind-down + Melatonin Window. https://help.risescience.com/hc/en-us/articles/40610919159575

## 4. Smart alarm (exact behaviour)
Primary: help article (May 2026) https://help.risescience.com/hc/en-us/articles/10960396186903 and April 2026 release post https://www.reddit.com/r/riseapp/comments/1sl9stt/
- "Wakes you during a lighter phase of sleep within a window around your set alarm time, using a gradual wake-up sequence with customizable sounds, volume, and vibrations." As you set the time it shows whether that wake time **adds to or reduces sleep debt** (the red bar under the alarm card in screenshot 7). Marketing: "aimed at debt and clock time, not a light-sleep guess".
- **Window length: unpublished.** Users describe "15 min before or after" on iPhone (**unconfirmed**). Android (since Apr 2026) fires at the exact time.
- **Signal for "lighter phase": unpublished.** Rise has no native staging; phone-on-bed not required.
- Setup: Profile > Smart Alarm > toggle > active days; **+ Alarm** for more; per-alarm Settings: Sounds and volume, Vibrations, **Gentle wake-up** (gradual ramp), Alarm tips. Auto-arms on chosen days.
- **iOS 26.1+ moved to AlarmKit**: rings through Silent/Focus, fires with app closed or after restart, full-screen alert with snooze/dismiss. Consequence: "Engage Your Brain" (open a favourite app after dismiss) discontinued; some users hit the iOS phantom-midnight-alarm bug. https://www.reddit.com/r/riseapp/comments/1r2yg1y/
- Pre-iOS-26: alarm only worked with the app open/in background (historical).
- **Sounds**: melodic library engineered ~500 Hz, 100-150 BPM; personal playlists **unconfirmed** (reviewers complain they can't). https://www.risescience.com/blog/how-to-wake-up-to-an-alarm
- Post-alarm notification 15 min later.
- **Apple Watch**: alarm must be set **in the Watch app, every night**; phone and Watch alarms **not synced**; Watch wakes with gentle haptics; no countdown on Watch. (This matches the watchOS smart-alarm extended runtime session constraint exactly; see appendix 03.)
- Rise does not pick a single wake time; it shows a **wake zone** and lets you pick any time in it.

## 5. Sleep tracking sources and editing
- Three modes (2026 help center): (1) **Automatic phone motion** ("Nightstand"): motion + steps + screen activity; phone within arm's reach; "accurate about 80% of the time"; Motion & Fitness permission. (2) **Mattress tracking**: accelerometer on the mattress near the body, not under pillow; must be **started each night** (Zz button); falls back to phone motion. (3) **Wearables** via Apple Health / Health Connect. https://help.risescience.com/hc/en-us/articles/40624579537303 ; https://help.risescience.com/hc/en-us/articles/4405262973591
- Older blogs mention tappigraphy and an acoustic/microphone mode; likely retired (**unconfirmed**).
- **Sleep Detection Buffer** setting for people who put the phone down early.
- Supported sources: Apple Watch (stages imported), Oura, WHOOP, Fitbit (via Health), Garmin, Samsung, Sleep Cycle, SleepWatch, AutoSleep, Pillow, Sleep++, Withings, Eight Sleep. Source priority = drag list in Profile. **Rise reads only; never writes to Apple Health.** https://help.risescience.com/hc/en-us/articles/40590044797335
- **Stages**: none computed; Apple Watch stages pulled in and shown on the timeline (screenshots 3-5 confirm the vertical hypnogram rail).
- Awake/split sessions: phone motion can miss wake-ups or register false ones; night-time phone use can end a session early. https://help.risescience.com/hc/en-us/articles/40610242681751
- **Editing**: Progress > Sleep Times > tap a night > drag sleep/wake; "press the screen around the desired time" to add awake time (screenshots 4-5: "Press to add awake time"). Edit up to 14 days back; entries < 20 min cannot be edited/deleted. Known UX issue: handles sit where the finger scrolls. https://help.risescience.com/hc/en-us/articles/17149556887447
- **Naps**: + Nap on Home / + on Energy; start/end then "Add & Review". Complaint: can't remove today's nap until tomorrow (**unconfirmed**).
- **Data export: not supported.**

## 6. Habits / reminders (timeline chips)
"20+" circadian-timed habits, added from the Energy tab; reminders toggled per habit under Tools > Habit Reminders. https://help.risescience.com/hc/en-us/articles/40620510022167
- Get bright light (>=10 min right after waking; 30 min if cloudy)
- Limit caffeine (final cup ~10-12h before bed; "10h before Melatonin Window")
- Avoid late meals (2-3h before bed)
- Avoid alcohol (3-4h before bed)
- Avoid late workouts (keep intense exercise out of wind-down)
- Blue-light glasses / dim lights (~90 min before bed)
- Sleep mask; Check your environment
- Brain dump (~15 min before bed; opens in-app note)
- Relaxation (guided sessions during wind-down)
- **Sleep Quality** self-rating prompt **90 min after waking** (screenshot 5: "Rate sleep quality" chip)
- Melatonin Window bedtime reminder; Evening routine / Wind down
- Sleep reset guide ("awake > 15 min, leave bed")
- Nap timing suggestions (afternoon dip; 10-20 min or 40-90 min)
- Morning-routine options (coffee timing, exercise, meditation, reading, to-do list)
- Peaks & Dips alerts
- "Take melatonin" (screenshot 6 shows it as a chip at ~20:30; supplement timing discussed in blogs)

## 7. Progress tab
- Past **14 nights**, toggles **Sleep Times / Sleep Debt / Sleep Quality**; bar chart + day list; tap to edit. No month/year view. https://help.risescience.com/hc/en-us/articles/40621710877719
- **Smart Schedule**: wake zone + recommended bedtime (Melatonin Window) + "how many days to pay back debt if you follow it" (the "GREAT IN 4 days" chip in screenshot 6). Spreads payback over ~25 extra min/night. https://www.reddit.com/r/riseapp/comments/1sxpr19/

## 8. Tools and Guidance
- **Tools**: Habit Reminders; Smart Alarm; Mattress detection start; Melatonin Window tool ("Data seem off?" questionnaire); Sleep sounds (white noise, nature loops); Guided sessions (autogenic training, ~2 min diaphragmatic breathing, ~6 min progressive muscle relaxation); Brain Dump; Sleep Reset guide; Calendar integration; **Partner Connect** (share debt with a friend). https://help.risescience.com/hc/en-us/articles/40610511674775
- **Guidance**: daily-tailored tips and guides based on data/goals.
- Paid add-ons: AI Expert (in-app AI coach, $19.99/$29.99 IAP) and Expert Chat / Sleep Clinic (telehealth).

## 9. Onboarding
- 41-47 screens, ~2-3 min quiz; every question optional: goal (productivity / energy / schedule / quality, pick one), challenges, energy strategies (caffeine, exercise, naps), sleep practices, profile (age, gender, wearable), weekday bed/wake times. Contextual science pop-ups. https://help.risescience.com/hc/en-us/articles/40557426345239
- Permissions: Motion & Fitness, Apple Health, notifications; pulls up to a year of phone data ("Synthesizing insights"). Output on day one: sleep need (adjustable), debt, Energy Schedule, Melatonin Window; pre-configures alarm, sounds, caffeine cutoff, habits.
- No chronotype question. **Hard paywall** after the quiz: 7-day trial then $69.99/yr.

## 10. Widgets, Watch, Live Activities, notifications
- iOS home + lock screen widgets: phase, time left in peak, grogginess end, debt, Melatonin Window; manage alarm and sounds. Widget shows a specific ideal wake time while the app shows a zone (user confusion). https://help.risescience.com/hc/en-us/articles/40590423725719
- Apple Watch app: complication = current energy level; app shows schedule, debt, Smart Alarm (set nightly, haptic wake); habit notifications and the 90-min quality prompt on the wrist; sleep data comes from Apple's Sleep app via Health. https://help.risescience.com/hc/en-us/articles/4405263000471
- Live Activities / Dynamic Island: no evidence (**likely absent**).
- Notifications: per-habit toggles, Peaks & Dips, Smart Alarm, quality check-in, post-alarm 15-min reminder.

## 11. Pricing
- No free tier. $69.99/yr with 7-day trial (14 via partner links); monthly ~$9.99; Lifetime $149.99 (periodic sale). Trustpilot 2.3/5 dominated by billing complaints. iOS 4.7 stars (~70.5k), Editors' Choice; Play 3.6 (~10k).

## 12. Android differences
- Smart alarm only since Apr 2026 (fires at exact time); no Calendar integration; no exercise boost; fewer widgets; company admits Android lags.

## 13. Praise and complaints (aggregate themes)
**Praise**: sleep debt as a single actionable number; energy schedule matches lived experience; timed caffeine/alcohol/wind-down reminders; no wearable needed; clean design; watch complication + widgets; coexists with Oura/Fitbit/Garmin.
**Complaints**: price / no free tier / silent trial conversion / double billing; alarm reliability (not firing, blank notification, phantom midnight alarm, phone/Watch not synced, no Watch countdown, limited sounds); phone-motion accuracy (awake counted as sleep, split nights); debt diverging from Oura/Watch; Melatonin Window ignoring a fixed alarm; wake zone vs widget wake time mismatch; no per-day wake goals; no nap toggle; no export; Android parity; debt number causing anxiety; "shame-based" notification tone.
**Wished for**: free tier; Watch countdown; synced alarms; custom wind-down tasks; per-day schedules; nap toggle; trends beyond 14 nights; native stages/HRV; notes on nights.

## 14. Open items (unconfirmed)
1. Exact 14-night weight decay (only "last night ~15%").
2. Debt to Energy Potential % mapping.
3. "Okay/Great/Super" labels and thresholds.
4. Smart-alarm window length and the sensor used for "lighter sleep" without a wearable.
5. Music/playlists as alarm sounds.
6. Whether the microphone mode still exists.
7. Exact copy of carousel deltas and Smart Schedule chip.
8. Live Activities (no evidence).
9. How imported Apple Watch stages are rendered (screenshots answer this: vertical hypnogram rail beside the timeline).
