# 9. The alarm set on the phone appears on the Watch, and edits on the Watch flow back

Blocked by: 3, 8
Status: done

## What to build

Whatever the user does to an alarm on one device shows up on the other. The Watch app lists the alarms, and can change the time, the wake-window length, the repeat days and the on/off switch; the phone reflects those changes and reschedules its backstop. One alarm document is shared, and when both sides edited while apart, each field keeps the newer edit.

## Acceptance criteria

- An alarm created on the phone appears on the Watch after the Watch app is next opened, without pairing steps in the app
- A change made on the Watch appears on the phone, and the phone's system alarm moves to the new time
- When both devices changed different fields of the same alarm while disconnected, both changes survive on both devices
- When both changed the same field, the newer edit wins on both devices; a tie goes to the phone
- Every publish bumps a revision so that a repeated identical document is still delivered, per spike 3's finding
- Deleting an alarm on either device removes it on the other
- With the counterpart unreachable, the editing device shows "waiting for Watch" or "waiting for iPhone" and nothing is lost
- Merge rules have unit tests in the core package using two replicas edited in every combination
