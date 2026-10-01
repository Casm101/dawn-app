# 14. Habit chips sit on the timeline at evidence-based times, with optional reminders

Blocked by: 13
Status: done

## What to build

The Energy timeline shows habit chips anchored to the user's schedule: morning light after waking, the caffeine cutoff, dim lights and wind-down before bed, a melatonin supplement time, and a "rate last night" prompt 90 minutes after waking. Each habit can be switched on or off and can send a notification at its time. The user can rate last night from the prompt.

## Acceptance criteria

- The chips and their offsets are: morning light from wake to one hour after; caffeine cutoff ten hours before the melatonin window; dim lights two hours before bedtime; wind-down 90 minutes before bedtime; melatonin supplement six and a half hours before bedtime when enabled; rate last night 90 minutes after wake
- Each chip sits on the timeline at its time and shows its icon and name; chips whose time has passed are dimmed
- Each habit has an on/off switch and a reminder switch in Tools; a reminder posts a local notification at the habit's time with the habit's name
- Rating last night from the chip or its notification records a 0 to 10 score on that night and the chip shows the score afterwards
- Turning a habit off removes its chip and cancels its pending notification
- Notifications are rescheduled whenever the schedule changes, and never fire during the user's sleep window
