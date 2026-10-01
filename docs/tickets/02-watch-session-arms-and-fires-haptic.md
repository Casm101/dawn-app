# 2. Watch wake-window session arms from the foreground and fires a haptic at window end

Blocked by: None
Status: ready for agent
Kind: spike (throwaway code, written answers are the deliverable)

## What to build

A throwaway Watch app lets the tester arm a smart-alarm session for a window later that night, then goes to sleep wearing the SE 2. At window start the session runs for its full length, logs what the app can see, and fires a repeating haptic at the end. The port of WakeTF's session controller is the starting point.

## Acceptance criteria

- The tester can arm a window up to 30 minutes long from the foreground app and see it confirmed
- watchOS launches the app at window start with the app not running, and the session reaches its end with a repeating haptic and the system Stop and Open buttons
- The log records the app's scene phase at launch, and whether scheduling the next session from inside the running session succeeds or fails, with the error
- The log records how many heart-rate samples arrived during the window without a workout session
- The log records whether the sensor recorder returned accelerometer samples for the hours before the window, while Apple's own sleep tracking was on
- Battery percentage at bedtime and at window end is written down
- Arming with the app in the background fails with the documented error, and that error is recorded
- The answers are recorded in the platform state document in the memory store and in the spike's notes
