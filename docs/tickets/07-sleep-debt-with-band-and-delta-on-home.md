# 7. Sleep debt with a band and a daily delta shows on Home

Blocked by: 6
Status: done

## What to build

Home shows the user's sleep debt in hours with one decimal, a band label, and the change since yesterday. Debt is the recency-weighted shortfall against the user's sleep need over the last 14 nights, naps included. Sleep need starts at a seed and drifts slowly from nights the user was not woken by an alarm; the user can also set it.

## Acceptance criteria

- Debt equals the weighted sum over the last 14 nights of (need minus slept), weights decaying so that last night carries about 15 percent, floored at zero
- Bands: under 5 hours is the good band, 5 to 10 hours the middle band, over 10 hours the high band, with the labels chosen in the UI package's tokens
- The delta shows the change since yesterday's value with a sign, and reads "new" when no earlier value exists
- Sleep need seeds at 8 hours 15 minutes, updates only from at least three alarm-free nights, moves at most 10 minutes per week, and stays within 5 to 11.5 hours
- The user can set sleep need by hand in Profile and the debt recomputes at once
- A nap counts toward its day's sleep, with a single nap credited at most 90 minutes
- Nights missing from the window count as neither shortfall nor surplus
- Fixture nights with known answers exercise every rule above in the core package's tests
