# Screenshot analysis (user-supplied, Rise iOS, captured 2026-09-30 12:25-12:26)

## Global chrome (all screens)
- Top bar: screen title, subtitle, profile avatar with a ring (progress ring around the avatar).
- Persistent bottom sheet ("dock") with drag handle, containing: expand chevron, alarm pill (08:20, purple = enabled), "Health" pill (zZ icon, sleep source), "+" button (add: nap / sleep / habit).
- Tab bar: Home, Progress, Energy, Tools, Guidance.
- Dark theme only in screenshots. Primary purple (#7C3AED-ish), orange for "Okay" state, pink for +debt delta, blue for REM, purple shades for Core/Deep, orange for Awake.

## 1. Home (12:25)
- Sleep debt gauge: big circle "8.7 hrs Sleep debt", with concentric arcs. Chip "Okay +0.4hrs" (state label + delta vs yesterday). Ring markers "Great 5" and "Super 0" (looks like counts of days in each band, or thresholds; unconfirmed).
- Sleep pills: "6h 22m Last night" (tap to open last night), "Motion" (phone-motion tracking mode), "+ Nap".
- "57% Energy Potential" heading (orange).
- Horizontal carousel of energy phases: "Morning peak — Until 13:48 — 15m shorter" (current, highlighted with orange border), "Next up: Afternoon dip 13:48-15:55", next card "...12m e[arlier]".
- NOTE: Home says 57% energy potential while Energy tab header says "Okay 66%". These are two different numbers: 66% is likely today's overall energy/sleep-debt score; 57% the current potential at this moment. Unconfirmed.

## 2. Progress (12:25) — "My Progress, Sep 17-30"
- Segmented control: Sleep Times | Sleep Debt | Sleep Quality.
- Sleep Times chart: 7 day columns (WED..WED), vertical time axis 23 → 11 (night spans midnight), each night drawn as stacked purple blocks (sleep segments, with zZ at top and sun at bottom), moon markers above showing target/bedtime line. Durations under each column (4h50m ... 6h22m, "--h --m" for tonight).
- FRI shows 11h 1m spanning into late morning: long sleep + segments.
- "Smart Schedule" card: "GREAT IN 4 days" → projected days until sleep debt reaches "Great" if schedule followed.
- "All sleep times" list: "Last night (Tuesday) 00:45 - 07:07 6h 22m >" , "Monday night ... 5h 49m >".

## 3. Energy — top of night (12:26) — "My energy schedule, Okay 66% ?"
- Vertical 24h timeline, hour labels at left (22, 23, 00, 01...), major/minor tick marks.
- Sleep session card: "Total sleep time 8h 15m", source badge "Apple Watch via Apple Health (i)", legend: Awake 16m, REM 2h 1m, Core 5h 33m, Deep 41m.
- Sleep drawn as vertically stacked segment cards: each with start time (zZ 00:39), end time (01:51 sun), "Press to add awake time" affordance (scissors icon) → split a segment by inserting an awake gap. Segment gaps (00:39→01:51, 01:52→...) = auto-detected awake gaps.
- Right rail: minute-resolution hypnogram as horizontal bars colored by stage (orange awake, blue REM, purple core, darker purple deep). Effectively a vertical hypnogram aligned to the timeline.
- Note: 8h 15m total vs Home "6h 22m last night" and Progress "00:45-07:07 6h 22m". Discrepancy: the timeline seems to show a different night (00:39 → 07:53+) than "last night". Possibly timeline shows tonight's projection/yesterday. Unconfirmed; flag.

## 4. Energy — early morning (12:26)
- Continues sleep segments 04:11→05:53, 05:54→07:41, 07:53→..., each "Press to add awake time".
- Right rail hypnogram continues; orange (awake) bars at 07:41-07:53 gap.
- Thin empty segment 07:41-07:53 rendered as a hollow rounded box (awake).

## 5. Energy — late morning/afternoon (12:26)
- "Morning peak · 6m shorter" panel (grey background band spanning the phase's time range).
- Energy curve: a smooth vertical bezier line coloured by gradient (purple → pink → orange = energy level, orange = high), with two grey "band" outlines behind it (looks like the ideal/expected curve envelope or yesterday's curve; unconfirmed).
- "Now" marker: horizontal white line with dot at ~12:26.
- Habit chips on the right rail, anchored at times: "Rate sleep quality" (~10:xx, pink/magenta icon), "Avoid caffeine" (~14:20, mug icon).
- "Afternoon dip" panel begins ~15:xx.

## 6. Energy — evening (12:26)
- "Evening peak · 1m shorter" panel from ~19:xx.
- Curve continues; habit chip "Take melatonin" at ~20:30.
- Grey background band 18:00-19:xx above evening peak = "Afternoon dip"? Actually the band ends at 19:xx; unlabelled portion.

## 7. Energy — alarm sheet (12:26)
- Timeline at 07-10, "Wake window" label spanning a grey band (~08:50?-09:xx?) Actually: alarm marker at 08:20 (dot on the axis + card "08:20 Tomorrow, S M T W T F S" with days highlighted M-F, hamburger to reorder/drag). Below the card, a red bar with red text (obscured — reads like "…delet… …" possibly "Sleep debt increase" warning or "…" ) then grey band "Wake window" from ~08:45 to ~09:50. So the alarm at 08:20 is BEFORE the wake window — the app is warning (red) that the alarm is earlier than the recommended wake window.
- Bottom sheet "Smart alarm": "08:20 Tomorrow" + toggle ON; day chips S M T W T F S (M-F on, T today outlined); "Sound & gentle wake" option row (signal-bars icon); "+ Add alarm for other days".
- Interpretation: Rise's "smart alarm" here is a repeating alarm with a wake window *recommendation* derived from the energy schedule; "gentle wake" likely = gradually increasing sound. Whether Rise moves the fire time within a window based on sleep stage is NOT evident from the screenshot — the researcher must confirm. The user's stated requirement (fire at the best moment within a range based on sleep stage) may exceed what Rise actually does.

## Derived requirement list (from screenshots only)
R1 Sleep import from Apple Health (Apple Watch) incl. stages; show source attribution.
R2 Phone "Motion" tracking mode as alternative source.
R3 Manual nap / sleep entry; edit segments; insert awake time (split).
R4 Sleep debt (rolling), labelled bands (Okay/Great/Super), daily delta.
R5 Energy schedule: phases (morning peak, afternoon dip, evening peak, presumably wind-down + melatonin window), energy curve, "now" marker, per-phase delta vs baseline ("6m shorter").
R6 Energy potential % (current) and daily score %.
R7 Habit reminders anchored on timeline (rate sleep quality, avoid caffeine, take melatonin, …) with notifications.
R8 Smart alarm: time, repeat days, enable toggle, "sound & gentle wake", multiple alarms, wake-window guidance, warning when alarm conflicts with window.
R9 Progress: 14-day header, 7-day sleep-times chart, sleep debt trend, sleep quality ratings, "Smart Schedule: GREAT IN N days" projection, list of all nights.
R10 Tools & Guidance tabs (content unknown from screenshots).
R11 Persistent dock: alarm pill, sleep source pill, quick add.
R12 Profile with ring (progress/streak?).
