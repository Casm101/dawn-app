# Prompt for installing Dawn on a physical iPhone

Paste everything below the line into a Claude Code session opened in this repository, with the iPhone plugged into the Mac.

---

Install the Dawn iOS app on my physical iPhone 13 (iOS 27.0.1) and get its Watch app onto my Apple Watch SE 2 (watchOS 26.6), then confirm both launch. This is ticket 5's last open criterion in `docs/tickets/05-fresh-clone-installs-on-phone-and-watch.md`.

**Where you are.** `/Users/christian.smith/Documents/Github/mini-apps/dawn-app`, a Swift 6 project with a hand-authored `Dawn.xcodeproj`, built with Xcode 27.0 on this Mac. Read `CLAUDE.md` first. The path to a device is `make install`, which runs `Scripts/install.sh`: it finds the first paired physical iPhone with `xcrun devicectl`, builds the `Dawn` scheme signed with the team in `Config/Team.xcconfig`, installs with `devicectl device install app`, and launches `com.casm101.dawn`. The Watch app is embedded in the iPhone app and installs through the Watch app on the phone; nothing is pushed to the Watch directly.

**Do these checks in order and stop at the first that fails, telling me exactly what to do on my side.**

1. `xcodebuild -version` reports Xcode 27. `make test`, `make build` and `make build-watch` pass.
2. `Config/Team.xcconfig` has a `DEVELOPMENT_TEAM` value. If it is empty, ask me for my team id (Xcode > Settings > Accounts, or developer.apple.com > Membership); do not guess one and do not commit the file, it is git-ignored.
3. `xcrun devicectl list devices` shows my iPhone with `pairingState` paired and Developer Mode enabled. If the phone is missing: I need to plug it in, unlock it, tap Trust, and turn on Settings > Privacy & Security > Developer Mode (the phone restarts). If Developer Mode shows as not enabled, say so and wait.
4. Xcode has prepared the device for iOS 27.0.1. If `xcodebuild` reports the device as not ready or needing preparation, tell me to open Xcode once with the phone connected and wait for "Preparing device" to finish, then retry.

**Then run `make install`.** Watch the output for signing problems and handle them like this:

- "No Account for Team" or "Unable to log in": I need to add my Apple ID in Xcode > Settings > Accounts; tell me and wait.
- A capability error about HealthKit or background delivery under a free Personal Team: do not remove or change entitlements or usage strings to get past it. Report the exact message; the decision is mine.
- An "Untrusted Developer" or "could not launch" result after a successful install on a free team: tell me to trust the developer under Settings > General > VPN & Device Management on the phone, then launch again with `xcrun devicectl device process launch --device <udid> com.casm101.dawn`.
- Never use `--no-verify`, never force-push, and never change `Dawn.xcodeproj` signing settings beyond what `Config/Team.xcconfig` provides. If `install.sh` itself has a bug, fix the script, run `sh -n` on it, and tell me what changed.

**Confirm the result.** After the launch, `xcrun devicectl device process list --device <udid>` should show the Dawn process. Then tell me to open the Watch app on the iPhone, scroll to "Available apps", and install Dawn if it has not appeared on the Watch by itself; the Watch app shows "Nothing to arm". A free Personal Team profile expires after seven days, so note the install date.

**Report.** The device name, iOS version and UDID used; the team type if the output reveals it (Personal Team or paid); whether the app launched; whether the Watch app installed; every manual step I had to take; and, if everything worked, set the `Status:` line of ticket 5 to `done`, commit that one change with the repository's commit attribution, and push to `main`.
