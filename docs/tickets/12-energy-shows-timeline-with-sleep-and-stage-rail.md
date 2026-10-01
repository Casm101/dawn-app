# 12. Energy shows today's vertical timeline with sleep segments, the stage rail and a now marker

Blocked by: 6
Status: ready for agent

## What to build

The Energy tab is a vertical 24-hour timeline from yesterday evening to tonight, with hour labels, last night's sleep drawn as segment cards, a rail beside them showing the stages minute by minute, and a line marking now. It scrolls to now on open. This is the surface later tasks put the energy curve and habit chips on.

## Acceptance criteria

- The timeline spans from 6 pm yesterday to 6 pm today with hour labels and quarter-hour ticks
- Each sleep segment is a card showing its start and end times; awake gaps between segments are visible
- The rail shows each minute's stage in the stage colours from the UI tokens, and is absent when the night has no stages
- A horizontal line with the current time marks now and moves without a relaunch
- The view opens scrolled so that now is in the upper third of the screen
- Scrolling drops no frames on the test iPhone with a full night of stage data, measured with Instruments
- With no night, the timeline still renders with hour labels and the now marker
