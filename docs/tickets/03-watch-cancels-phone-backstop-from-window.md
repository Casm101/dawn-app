# 3. Watch cancels the phone backstop from inside the wake window

Blocked by: 1, 2
Status: ready for agent
Kind: spike (throwaway code, written answers are the deliverable)

## What to build

The two spike apps are joined. The phone schedules a backstop alarm at window end and sends the plan to the Watch as an application context. Inside the running session the Watch sends a live "wake now" message; the phone, woken in the background, cancels the backstop. The tester sleeps through it and records whether the backstop stayed silent.

## Acceptance criteria

- With the phone locked and the app killed, a message sent from inside the session wakes the phone app and the backstop alarm does not fire
- The Watch's reachability flag inside the session is logged every 30 seconds, and its value is recorded
- When the live message fails, the queued transfer arrives later and the backstop alarm still rings at window end
- Sending the same application context twice in a row is tried, and whether the second delivery arrived is recorded
- The phone shows a Watch-sent event after the phone app is next opened, proving the queued channel survives suspension
- The answers are recorded in the platform state document in the memory store and in the spike's notes
