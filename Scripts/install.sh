#!/bin/sh
# Builds Dawn signed for the first connected iPhone and installs it there.
# The Watch app rides along inside the iPhone app and installs through it.
set -eu
PROJECT="$1"; SCHEME="$2"; CONFIG="$3"; DERIVED="$4"
if ! grep -qE '^DEVELOPMENT_TEAM *= *[A-Z0-9]+' Config/Team.xcconfig; then
  echo "Set DEVELOPMENT_TEAM in Config/Team.xcconfig first." >&2; exit 1
fi
DEVICES_JSON="$(mktemp)"
xcrun devicectl list devices --json-output "$DEVICES_JSON" >/dev/null
DEVICE_ID="$(python3 - "$DEVICES_JSON" <<'PY'
import json, sys
data = json.load(open(sys.argv[1]))
for d in data.get("result", {}).get("devices", []):
    props = d.get("hardwareProperties", {})
    conn = d.get("connectionProperties", {})
    if props.get("deviceType") == "iPhone" and conn.get("pairingState") == "paired":
        print(d["identifier"]); break
PY
)"
if [ -z "$DEVICE_ID" ]; then echo "No paired iPhone found. Connect one and trust this Mac." >&2; exit 1; fi
xcodebuild -project "$PROJECT" -scheme "$SCHEME" -configuration "$CONFIG" \
  -destination "id=$DEVICE_ID" -derivedDataPath "$DERIVED" -allowProvisioningUpdates build
APP="$DERIVED/Build/Products/$CONFIG-iphoneos/Dawn.app"
xcrun devicectl device install app --device "$DEVICE_ID" "$APP"
echo "Installed Dawn on $DEVICE_ID. The Watch app installs through the Watch app on the iPhone."
