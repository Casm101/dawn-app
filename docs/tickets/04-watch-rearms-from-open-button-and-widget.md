# 4. Watch re-arms tomorrow's window from the alarm's Open button and from a Smart Stack widget button

Blocked by: 2
Status: ready for agent
Kind: spike (throwaway code, written answers are the deliverable)

## What to build

The spike Watch app arms the next window whenever it becomes active and a window is due within 36 hours. The tester tries every route that opens the app: the Open button on the alarm alert, a bedtime local notification, a complication tap, and a Smart Stack widget button backed by an App Intent that opens the app.

## Acceptance criteria

- Tapping Open on the alarm alert after a wake leaves the app active and the next window is armed without further taps
- Tapping Stop on the alarm alert does not arm anything, and the app shows "not armed" when next opened
- A Smart Stack widget button that opens the app results in an armed window, and the log records the scene phase at the moment the intent ran
- A local notification tapped at bedtime results in an armed window
- Opening the app with nothing due within 36 hours arms nothing and says so
- The answers are recorded in the platform state document in the memory store and in the spike's notes
