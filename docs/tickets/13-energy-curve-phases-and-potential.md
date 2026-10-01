# 13. Energy shows the energy curve and labelled phases; Home shows energy potential and the phase carousel

Blocked by: 7, 12
Status: ready for agent

## What to build

From the user's recent sleep times and last night, Dawn predicts today's energy as a curve on the timeline and labels its phases: grogginess, morning peak, afternoon dip, evening peak, wind-down and melatonin window. Home shows the current energy potential as a percentage and a carousel of the phases with their times and how much each moved since yesterday.

## Acceptance criteria

- The curve comes from the three-process alertness model with the published constants, evaluated on a 5-minute grid and cached until a night changes
- Phase anchors: dim-light melatonin onset is two hours before habitual bedtime; the melatonin window starts about an hour after that and lasts an hour; peaks and dips are found from the curve with the offset priors in the algorithms appendix
- Each phase is drawn as a labelled band on the timeline, in order, with no overlaps and no gaps between wake and bedtime
- Energy potential is derived from sleep debt, is 100 at zero debt, and never falls below 20
- The Home carousel shows the current phase first with "until" its end time, then the next phases with their spans
- Each phase card shows the change since yesterday in minutes, or "same" when unchanged
- A user with fewer than three nights of history sees the schedule anchored on their onboarding bed and wake times with a "learning" label
- The model, the anchors and the phase finder have unit tests with fixture sleep histories and expected phase times
