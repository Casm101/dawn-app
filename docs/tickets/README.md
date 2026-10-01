# Tickets

Written 2026-09-30 from `../00-investigation.md` and `../01-architecture-direction.md`, in the order they can be picked up. Tasks whose blockers are all done come first. Tasks 1, 2 and 5 can start now, in parallel.

Spike tickets (1 to 4) are throwaway code; their deliverable is written answers, recorded in the platform state document in the memory store and in the spike's own notes.

| # | Ticket | Blocked by | Kind |
|---|---|---|---|
| 1 | [Phone backstop alarm rings on the iPhone and on the SE 2 through Silent and Focus](01-backstop-alarm-rings-on-phone-and-watch.md) | None | spike |
| 2 | [Watch wake-window session arms from the foreground and fires a haptic at window end](02-watch-session-arms-and-fires-haptic.md) | None | spike |
| 5 | [A fresh clone installs Dawn on the iPhone and the SE 2 with one make command](05-fresh-clone-installs-on-phone-and-watch.md) | None | build, skeleton in place and CI green; device install pending |
| 3 | [Watch cancels the phone backstop from inside the wake window](03-watch-cancels-phone-backstop-from-window.md) | 1, 2 | spike |
| 4 | [Watch re-arms tomorrow's window from the alarm's Open button and from a Smart Stack widget button](04-watch-rearms-from-open-button-and-widget.md) | 2 | spike |
| 6 | [Last night's sleep from Apple Health shows on Home with its source and awake time](06-last-night-from-apple-health-on-home.md) | 5 | build |
| 8 | [An alarm set on the phone rings through Silent and Focus on its days with a gentle-wake sound](08-alarm-rings-through-silent-and-focus.md) | 1, 5 | build |
| 7 | [Sleep debt with a band and a daily delta shows on Home](07-sleep-debt-with-band-and-delta-on-home.md) | 6 | build |
| 11 | [Progress shows the last 14 nights as a Sleep Times chart with a list, and a night opens to its segments](11-progress-shows-14-nights-and-opens-a-night.md) | 6 | build |
| 12 | [Energy shows today's vertical timeline with sleep segments, the stage rail and a now marker](12-energy-shows-timeline-with-sleep-and-stage-rail.md) | 6 | build |
| 9 | [The alarm set on the phone appears on the Watch, and edits on the Watch flow back](09-alarm-syncs-both-ways-with-watch.md) | 3, 8 | build |
| 13 | [Energy shows the energy curve and labelled phases; Home shows energy potential and the phase carousel](13-energy-curve-phases-and-potential.md) | 7, 12 | build |
| 10 | [The Watch wakes the wearer when they stir inside the window, and the phone backstop is cancelled](10-watch-wakes-wearer-in-window-and-cancels-backstop.md) | 2, 3, 4, 9 | build |
| 16 | [A night can be corrected: adjust sleep and wake, insert awake time, add a nap](16-night-can-be-corrected-and-naps-added.md) | 11 | build |
| 14 | [Habit chips sit on the timeline at evidence-based times, with optional reminders](14-habit-chips-on-timeline-with-reminders.md) | 13 | build |
| 15 | [The alarm sheet shows the wake zone and whether the chosen time adds to or pays down debt](15-alarm-sheet-shows-wake-zone-and-debt-effect.md) | 8, 13 | build |

Status is kept in each ticket's header. Move a ticket to `done` by editing its status line; do not delete tickets.
