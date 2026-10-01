# Prompt for an unattended build of the Dawn tickets

Paste everything below the line into a fresh Claude Code session (Opus 5.5) opened in this repository. Before pasting, do the prerequisites it lists; it will check them and stop if one is missing.

---

Build Dawn: Smart Alarm from its tickets, unattended, using the dt-auto-develop skill once per ticket.

**Where you are.** The repository is `/Users/christian.smith/Documents/Github/mini-apps/dawn-app`, an open-source iOS 26 and watchOS 26 app in Swift 6 with six local packages and four app targets. Read, in this order, before touching anything: `CLAUDE.md`, `docs/01-architecture-direction.md`, `docs/tickets/README.md`, then the ticket you are about to build. `docs/00-investigation.md` and `docs/research/` hold the evidence behind the design; consult them when a ticket cites an appendix. Skip dt-investigation of the codebase at the start of each ticket unless the ticket touches code you have not read yet in this session; the docs already carry the investigation.

**Prerequisites, check them first and stop if any fails.** The tree is committed and `main` is pushed to `origin` on GitHub, `gh` is authenticated, the first CI run on `main` is green, `make test`, `make build` and `make build-watch` pass locally, and iOS 26 and watchOS 26 simulator runtimes are installed (`xcrun simctl list runtimes` lists both). `Config/Team.xcconfig` exists; never edit it and never run `make install`.

**Run order.** Work these tickets one at a time, each as its own full dt-auto-develop cycle from branch to merged pull request, in this order: 06, 08, 07, 11, 12, 09, 13, 10, 16, 14, 15. Ticket 05 is done. Tickets 01 to 04 are spikes and are not yours; their answers are given to you below as requirements. Do not start a ticket before every ticket it lists under "Blocked by" is merged, except where that blocker is a spike.

**How the skill's phases apply here.**

- Phase 1: the task is the ticket's Markdown file. The definition of done is its acceptance criteria, verbatim. The scope boundary is the ticket's "What to build" plus the files the criteria require; touch nothing else.
- Phase 2: branch from `main` as `CLAUDE.md` describes, `ticket/NN-short-slug`.
- Phase 4: self-grill and log every answer as an assumption, as the skill says. Anything listed under "Given" below is a requirement, not an assumption.
- Phase 5: slice the ticket into vertical sub-tasks; the tickets themselves are already approved, so do not re-slice the whole project.
- Phase 6: `dt-implement` with Swift Testing. `make test` is the suite; a package's own `swift test` is the single-package check. Never weaken a test. Every file you add follows `CLAUDE.md`: one type per file, under about 120 lines, no `#available`, no third-party code, tunables in a `Tuning` type beside their tests.
- Phase 6b: there is no browser. Use the iOS Simulator tools in this app (build, launch, screenshot, tap) on an iPhone and a Watch simulator to walk the visible half of the acceptance criteria, and keep the screenshots. Criteria that need a physical Watch, an overnight run, Apple Health data or an alarm firing through Silent cannot be checked in a simulator: list them in the PR under "How to check" as steps for a person, leave the manual-testing box unticked, and say in your report that they are unverified. Seed simulator Health data through the Health app on the simulator where a ticket needs a night of sleep.
- Phase 7: after the PR is open and CI is green, squash-merge it into `main`, delete the branch, and start the next ticket from the updated `main`. I am the owner of this repository and I authorise merging for this run; this overrides the skill's never-merge rule for this repository only. Do not merge a PR whose CI is red. If CI fails for a reason outside the ticket (runner, Xcode version, workflow file), stop and report; the workflow file is not yours to change.
- Phase 8: the PR description uses `.github/pull_request_template.md`, links the ticket, and sets the ticket's `Status:` line to `done` in the same change. Nothing about how the PR was produced goes into it.
- Phase 8b: the memory store's subject for this project is `personal/dawn-app`. Record decisions there, never transcripts.

**Given, so they are requirements rather than assumptions.** These stand in for the spike answers until a person runs the spikes; each lives behind a named tunable so it can change without touching a ticket's behaviour.

- AlarmKit: schedule with `.relative` for repeating alarms and `.fixed` only for a computed early fire; the shortest lead time for a fresh alarm is 90 seconds; changing an alarm is always cancel then schedule with a new id; the system forwards the alert to the paired Watch and the app must not rely on `stopIntent` to learn the user is up.
- Watch session: `start(at:)` is called only when the app's scene phase is active; the app launched by the system for a session is not active, so nothing is scheduled from inside it; arming happens on every activation within 36 hours of the next window, from the alert's Open button, and from a bedtime nudge shown only when nothing is armed. The window is 10 to 30 minutes, default 30.
- Sync: the alarm document goes over `updateApplicationContext` with per-field last-writer-wins, phone winning ties; every publish bumps `revision`; events go over `transferUserInfo` keyed by event id; the live "wake now" uses `sendMessage` with `transferUserInfo` as fallback; `isReachable` is treated as unreliable inside a session.
- Sensors: passive heart rate inside the window may be sparse; the arousal rule works from motion alone when it is; no workout session is ever started; no raw samples are persisted.
- Data: this app has no users and no stored data yet, so defining new SwiftData models is in scope and is not a migration. Changing a model that is already on `main` in a way that would need a migration is still a stop.
- Numbers: use the constants and thresholds in `docs/research/04-sleep-science-and-algorithms.md` ("Recommended algorithms for v1") and the ticket text. Where the two differ, the ticket wins.
- Copy: the band labels for sleep debt are "Okay" under 5 hours, "Building" 5 to 10, "High" over 10. Other user-facing strings are yours to write, in plain English, through the string catalogue.

**Still a stop, whatever the ticket says.** A test you would have to weaken, skip or delete; a change to the CI workflow, the Makefile's signing steps, entitlements or usage strings beyond what a ticket names; a third fix attempt on the same failing test; two review rounds without convergence; a ticket whose criteria you cannot restate as checkable statements; anything that would need the physical Watch to know whether the design is right. Stop the way the skill describes, run dt-handoff, leave the branch and any open PR as they are, and report.

**Hand back at the end, or at a stop.** One report covering the whole run: for each ticket, its PR URL, merged or open, the suite result, what the review found and what you did with each finding, the screenshot paths, and the unverified device-only criteria; then every tripwire; then the assumption logs of all tickets, highest risk first. Finish by pushing the memory-store commits you made.
