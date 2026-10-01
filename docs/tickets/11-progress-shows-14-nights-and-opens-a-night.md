# 11. Progress shows the last 14 nights as a Sleep Times chart with a list, and a night opens to its segments

Blocked by: 6
Status: done

## What to build

The Progress tab shows two weeks of nights as vertical bars on a night-time axis, with each night's duration under its column and a list of nights below. Tapping a night opens it with its sleep segments, awake gaps, stage totals and source. The Sleep Debt and Sleep Quality segments exist but show "coming later" placeholders.

## Acceptance criteria

- The chart shows the last 14 nights, seven per page, oldest left, each night drawn from bedtime to wake on an axis that runs across midnight
- A night with several segments shows them stacked with the gaps visible
- Tonight, before any sleep, shows a dashed placeholder with "--h --m"
- The list under the chart shows each night's date label ("Last night", "Monday night"), bed and wake times, and duration
- Opening a night shows its segments in order, awake gaps, stage totals when present, and the source
- Nights missing from Health leave a gap in the chart and are absent from the list rather than shown as zero
- Scrolling the chart back a week shows the previous seven nights
