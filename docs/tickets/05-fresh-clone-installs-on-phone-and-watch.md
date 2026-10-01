# 5. A fresh clone installs Dawn on the iPhone and the SE 2 with one make command

Blocked by: None
Status: built 2026-09-30; awaiting `make install` on the user's devices and the first CI run after push

## What to build

A contributor clones the repository, copies the team config template, and runs one make target that builds and installs the iOS app and the Watch app on paired devices. Continuous integration builds everything unsigned on every push. The repository carries the six packages (core, health, sync, AlarmKit, wrist, UI) and the four app targets (iOS app, Watch app, iOS widgets, Watch widgets), each compiling with a placeholder, plus the coding rules and the licence.

## Acceptance criteria

- `make install` on a Mac with Xcode 27 builds and installs both apps on a paired iPhone and Watch using a team id from a git-ignored config copied from a committed template
- `make test` runs the core package's tests on macOS without a simulator or device
- A GitHub Actions workflow builds all targets unsigned and runs the core tests, and is green
- Deployment targets are iOS 26.0 and watchOS 26.0 on every target, Swift 6 with strict concurrency complete
- Bundle identifiers use the prefix `com.casm101.dawn`; the app's display name is "Dawn"
- The Watch app declares the alarm background mode and the health entitlement; the iOS app declares the AlarmKit and Health usage strings
- Each of the six packages has at least one type and one test, and no package imports a platform framework except the one it exists to wrap
- The repository contains an Apache-2.0 licence, an attributions file, a privacy statement, and a `CLAUDE.md` with the coding rules from the direction document
- The `.gitignore` excludes build output, user data, the team config, and the scratch folder
