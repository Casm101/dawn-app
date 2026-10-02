# 15. The alarm sheet shows the wake zone and whether the chosen time adds to or pays down debt

Blocked by: 8, 13
Status: done

## What to build

When the user sets or edits an alarm, the timeline behind the sheet shows the predicted wake zone as a band, and the alarm card shows a line saying how the chosen time changes tomorrow's debt, in red when it adds debt and in the accent colour when it pays some down. The user can drag the alarm marker along the timeline.

## Acceptance criteria

- The wake zone is drawn on the timeline as a band from 30 minutes before to 30 minutes after the habitual wake time
- The line under the alarm card reads "+Xh Ym to sleep debt" or "pays down Xh Ym", computed from the predicted bedtime, the chosen wake time and sleep need
- The line is red when the alarm is earlier than the wake zone and the accent colour otherwise
- Dragging the alarm marker on the timeline changes the alarm time in five-minute steps and updates the line live
- The wake-window band for the smart alarm is shown ending at the alarm time with its configured length
- With no schedule yet (fewer than three nights), the wake zone comes from the onboarding wake time and the line says so
