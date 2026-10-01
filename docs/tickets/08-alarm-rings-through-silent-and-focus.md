# 8. An alarm set on the phone rings through Silent and Focus on its days with a gentle-wake sound

Blocked by: 1, 5
Status: ready for agent

## What to build

The user sets an alarm on the phone with a time, repeat days, and a sound, and it rings at that time through Silent and Focus with the app closed, on the Lock Screen and on the paired Watch. Several alarms can exist; each can be toggled, edited, deleted and snoozed. The gentle-wake sound ramps within the bundled clip.

## Acceptance criteria

- An enabled alarm rings on each selected weekday at the set minute with the phone on Silent, in Sleep Focus, and the app not running
- Stop dismisses it; Snooze rings again after the configured interval
- A disabled alarm never rings; deleting an alarm removes it from the system as well
- The user can have more than one alarm, for example weekday and weekend
- The app reconciles its list with the system's on every launch so that an alarm removed elsewhere is not shown as active
- Choosing a sound plays a preview; the shipped sounds are CC0 and listed in the attributions file
- The alarm alert appears on the paired Watch with Stop, as observed in spike 1
- The lead time and cancel rules learned in spike 1 are respected when an alarm is edited close to its fire time
