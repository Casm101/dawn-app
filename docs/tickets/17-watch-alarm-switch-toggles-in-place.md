# 17. On the Watch, an alarm's switch turns it on or off without opening its editor

Blocked by: 9
Status: done

## What to build

Ticket 09's Watch list shows each alarm with its switch, but the whole row is the link to the editor, so tapping the switch opens the editor instead of switching the alarm. Found while walking ticket 10, whose Watch walk had to use the editor's On switch instead. The switch should work in place, and the rest of the row should still open the editor.

## Acceptance criteria

- Tapping the switch on an alarm in the Watch list turns the alarm on or off, and the list stays on screen
- Tapping the alarm's time or window opens its editor, as before
- Switching an alarm off from the list stands down a wake window armed for it, as ticket 10 requires of any edit
- The change reaches the phone like any other Watch edit
