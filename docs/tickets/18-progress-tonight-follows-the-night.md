# 18. Progress keeps tonight on the night still to come until morning

Blocked by: 11
Status: done

## What to build

Progress marks tonight's slot with a dashed column and "--h --m", and names nights "Tonight", "Last night" or by weekday. Both treat tonight as the evening of today's date, so after midnight tonight moves to the next evening while the user has not slept yet. At 00:51 on a Friday, the dashed column sits on Friday. Thursday's column stays empty, and the sleep about to start will land there, since a night belongs to the evening it began. The night still to come should stay tonight until daytime starts, the same hour that separates naps from nights.

## Acceptance criteria

- Between midnight and the start of daytime (`Tuning.Sleep.daytimeStartHour`), Progress's tonight slot is the evening that began the day before, and that evening's night is labelled "Tonight"; the evening before it is "Last night"
- From the start of daytime, tonight is today's evening, as before
- After midnight the fourteen slots still end with tonight, and the oldest night shown can still be corrected
