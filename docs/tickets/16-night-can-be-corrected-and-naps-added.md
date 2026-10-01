# 16. A night can be corrected: adjust sleep and wake, insert awake time, add a nap

Blocked by: 11
Status: ready for agent

## What to build

Opening a night lets the user drag its start and end, split a segment by inserting an awake gap at a chosen time, delete a segment, and add a nap for any day in the last 14 days. Edits are kept beside the imported data, never written back to Health, and debt and the schedule recompute from the corrected night.

## Acceptance criteria

- Dragging a segment's start or end changes it in five-minute steps and shows the new duration live
- Pressing on a segment inserts an awake gap of ten minutes at that point, which can then be dragged longer or shorter
- A segment shorter than 20 minutes cannot be created; the UI snaps back and says why
- Adding a nap asks for a day, start and end, and the nap appears on that day in Progress and on the timeline
- Edits survive relaunch and a fresh Health import; an edited night shows an "edited" mark and can be reset to the imported data
- Nothing is written to Apple Health
- Debt and the energy schedule reflect the corrected night immediately
- Edits are limited to the last 14 days
