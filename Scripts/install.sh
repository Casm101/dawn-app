#!/bin/sh
# Builds Dawn signed for the first connected physical iPhone and installs it there.
# The Watch app rides along inside the iPhone app and installs through the Watch app on the iPhone.
set -eu
PROJECT="$1"; SCHEME="$2"; CONFIG="$3"; DERIVED="$4"
if ! grep -qE '^DEVELOPMENT_TEAM *= *[A-Z0-9]{6,}' Config/Team.xcconfig; then
  echo "Set DEVELOPMENT_TEAM in Config/Team.xcconfig first (Xcode > Settings > Accounts shows it)." >&2; exit 1
fi
DEVICES_JSON="$(mktemp)"
xcrun devicectl list devices --json-output "$DEVICES_JSON" >/dev/null
DEVICE="$(python3 - "$DEVICES_JSON" <<'PY'
import json, sys
data = json.load(open(sys.argv[1]))
for d in data.get("result", {}).get("devices", []):
    hw = d.get("hardwareProperties", {})
    conn = d.get("connectionProperties", {})
    props = d.get("deviceProperties", {})
    if hw.get("deviceType") != "iPhone": continue
    if hw.get("reality", "physical") != "physical": continue
    if conn.get("pairingState") != "paired": continue
    udid = hw.get("udid") or d.get("identifier")
    print(udid, props.get("name", "iPhone"), props.get("osVersionNumber", "?"), props.get("developerModeStatus", "?"))
    break
PY
)"
if [ -z "$DEVICE" ]; then
  echo "No paired physical iPhone found. Plug it in, unlock it, tap Trust, and check Settings > Privacy & Security > Developer Mode." >&2
  exit 1
fi
set -- $DEVICE
UDID="$1"; shift
echo "Target: $* ($UDID)"
xcodebuild -project "$PROJECT" -scheme "$SCHEME" -configuration "$CONFIG" \
  -destination "id=$UDID" -derivedDataPath "$DERIVED" -allowProvisioningUpdates build
APP="$DERIVED/Build/Products/$CONFIG-iphoneos/Dawn.app"
xcrun devicectl device install app --device "$UDID" "$APP"
xcrun devicectl device process launch --device "$UDID" com.casm101.dawn || true
echo "Installed and launched Dawn on $UDID. Open the Watch app on the iPhone to install the Watch app if it does not appear by itself."
