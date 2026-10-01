# Dawn: Smart Alarm

iOS 26 and watchOS 26, Swift 6, SwiftUI, Apple frameworks only. Read `docs/01-architecture-direction.md` before changing structure and `docs/tickets/README.md` before starting work.

## Rules

- One type per file. The file name is the type name. Keep files under about 120 lines; split at 150.
- `Packages/DawnCore` imports Foundation only. Platform frameworks live in the package named for them, behind a protocol with a fake in its tests.
- Swift 6 strict concurrency. Sensors are actors. UI state is `@Observable`. No Combine. No `@unchecked Sendable` without a comment naming the lock.
- No third-party dependencies. No analytics, no network, no raw sensor persistence. Release logs carry no health values.
- Tunable constants live in a `Tuning` type next to their tests. Prose docs never restate them.
- Strings go through `String(localized:defaultValue:)` into the string catalogue.
- Views compose atoms from `DawnUI`; no literal colours or paddings in views.
- Tests use Swift Testing. Every package has tests that run on macOS with `swift test`.
- No `#available` checks: the floor is iOS 26 / watchOS 26.

## Branches and pull requests

- One branch and one pull request per ticket, from `main`, named `ticket/NN-short-slug` after the ticket file, for example `ticket/06-last-night-on-home`.
- A pull request closes by editing the ticket's `Status:` line to `done` in the same change.
- Pull requests target `main` only.

## Commands

- `make test` runs every package's tests on macOS.
- `make build` builds the iOS app unsigned; `make build-watch` the Watch app.
- `make install` signs and installs on the first connected iPhone (needs `Config/Team.xcconfig`).

## Ported code

Anything taken from another project is listed in `ATTRIBUTIONS.md` before it lands.
