# 1. Phone backstop alarm rings on the iPhone and on the SE 2 through Silent and Focus

Blocked by: None
Status: ready for agent
Kind: spike (throwaway code, written answers are the deliverable)

## What to build

A throwaway iPhone app schedules an AlarmKit alarm a few minutes out while the phone is on Silent with Sleep Focus on and the app killed. The tester wears the SE 2 and records what happens on both screens when it fires, then repeats with cancel-and-reschedule to measure how close to the fire time an alarm can still be changed.

## Acceptance criteria

- The alarm fires with the phone locked, on Silent, in Sleep Focus, with the app not running
- The tester has written down, for the Watch: whether a haptic played, whether Snooze was offered, and whether Stop on the wrist dismissed the phone alert
- The tester has written down the shortest lead time at which a freshly scheduled fixed alarm still fired on time, tried at 5, 2, 1 minute and 30 seconds
- Cancelling an alarm and scheduling a new one with the same id, and with a new id, both behave as recorded
- A custom bundled sound under 30 seconds loops until Stop
- The answers are recorded in the platform state document in the memory store and in the spike's notes
