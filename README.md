# Dawn: Smart Alarm

An open-source sleep tracker and smart alarm for iPhone and Apple Watch. Dawn reads your sleep from Apple Health, keeps a sleep-debt and energy schedule, and wakes you inside a window when your wrist says you are stirring.

Requires iOS 26 and watchOS 26. Built with Swift 6 and only Apple frameworks.

## Build

```sh
make config     # creates Config/Team.xcconfig from the template; fill in your team id
make test       # package tests on macOS, no simulator needed
make build      # iOS app, unsigned
make install    # signed build onto the first connected iPhone; the Watch app installs through it
```

## Layout

- `Apps/` the four targets: iOS app, Watch app, iOS widgets, Watch widgets
- `Packages/` six local packages: DawnCore (pure domain), DawnHealth, DawnSync, DawnAlarmKit, DawnWrist, DawnUI
- `docs/` the investigation, the architecture direction and the tickets

See `CLAUDE.md` for the coding rules and `docs/tickets/README.md` for what to pick up next.

Licensed under Apache-2.0. See `ATTRIBUTIONS.md` for ported code and data.
