# 6. Last night's sleep from Apple Health shows on Home with its source and awake time

Blocked by: 5
Status: ready for agent

## What to build

The user opens Dawn in the morning, grants Health read access for sleep, and sees last night on Home: total asleep time, time awake during the night, the stage totals when a Watch recorded them, and the source ("Apple Watch via Apple Health"). Sleep samples from Health become nights the rest of the app can use.

## Acceptance criteria

- On first launch Home explains why Health access is needed and asks once; declining leaves Home usable with an empty state that links to Settings
- Last night appears as one night even when Health holds several sleep samples with gaps, grouping samples with gaps under three hours
- Asleep time excludes awake samples; awake time is shown separately
- Stage totals (awake, REM, core, deep) appear when the samples carry stages, and are absent, not zero, when they do not
- The source name comes from the sample's source and is shown under the night
- A nap (a session under two and a half hours, ending before the evening) is listed as a nap, not as last night
- New samples that arrive after launch, as Watch stages do after wake, update Home without a relaunch
- With no sleep in Health for the past two days, Home shows an empty state that says so
