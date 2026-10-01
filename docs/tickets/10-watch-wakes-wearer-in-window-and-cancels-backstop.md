# 10. The Watch wakes the wearer when they stir inside the window, and the phone backstop is cancelled

Blocked by: 2, 3, 4, 9
Status: ready for agent

## What to build

The night before, the Watch arms the wake window for the next alarm whenever the app becomes active, and nudges once at bedtime if nothing is armed. Inside the window the Watch samples wrist motion and passive heart rate, scores each 30-second epoch, and wakes the wearer with a repeating haptic on the first signs of stirring, or at the window end. The phone's backstop alarm is cancelled when the Watch fires early. The outcome (when, why, which sensors) is logged and shown on both devices.

## Acceptance criteria

- Opening the Watch app within 36 hours of the next enabled alarm arms its window and shows "Armed" with the window times; opening it with nothing due shows "Nothing to arm"
- A bedtime notification and a Smart Stack widget appear only when the next window is unarmed, and tapping either arms it
- Tapping Open on the wake alert arms the following night
- Inside the window, sustained movement for two consecutive epochs after a one-minute warm-up fires the haptic; a strong burst fires it after 30 seconds; no movement fires it at the window end minus a safety margin
- When the Watch fires early, the phone's backstop for that alarm does not ring; when the message fails, the backstop rings at the window end
- The session ends when the wearer taps Stop; if the system invalidates the session before firing, the backstop still rings
- No raw motion or heart-rate samples are persisted; only the outcome and aggregate diagnostics are
- The scorer, the epoch aggregation and the window decision are pure types with unit tests ported from WakeTF and extended for the epoch model
- Every session outcome appears in the alarm's history on the phone
