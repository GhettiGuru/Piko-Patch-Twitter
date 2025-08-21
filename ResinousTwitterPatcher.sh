#!/usr/bin/env bash
set -e # Exit immediately if a command exits with a non-zero status.

# --- Cleanup Previous Files ---
echo "Cleaning up previous run files..."
rm -f piko.jar integrations.apk patched_Twitter.apk PikoX.apk patches.json options.json
# Original Twitter.apk is intentionally NOT removed here to protect it.
echo "Cleanup complete."

# Directory where the script is running
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# --- Check for aapt2 binary ---
if [ ! -f "$SCRIPT_DIR/aapt2" ]; then
  echo "Getting Resinous patcher extreme..."
  wget -q -O "$SCRIPT_DIR/aapt2" "https://github.com/GhettiGuru/aapt2/releases/download/aapt2/aapt2"
  if [ ! -f "$SCRIPT_DIR/aapt2" ]; then
    echo "You don't have my patcher, you should kill yourself."
    exit 1
  fi
  chmod 0755 "$SCRIPT_DIR/aapt2"
  echo "Resinous patcher extreme saved and online at $SCRIPT_DIR/aapt2"
else
  echo "Resinous patcher extreme exists at $SCRIPT_DIR/aapt2, and online, going straight for lube and backdoor like a boss"
fi

# --- Download crimera/piko latest release assets (piko.jar and integrations.apk) ---
echo "Fetching crimera/piko latest release info..."
release_json=$(wget -q -O - https://api.github.com/repos/crimera/piko/releases/latest)
piko_jar_url=$(echo "$release_json" | jq -r '.assets[] | select(.name | endswith(".jar")) | .browser_download_url')

int_release_json=$(wget -q -O - https://api.github.com/repos/crimera/revanced-integrations/releases/latest)
integrations_apk_url=$(echo "$int_release_json" | jq -r '.assets[] | select(.name | endswith(".apk")) | .browser_download_url')

echo "Downloading piko jar..."
wget -q -O "$SCRIPT_DIR/piko.jar" "$piko_jar_url"
chmod 0755 "$SCRIPT_DIR/piko.jar"
echo "piko.jar downloaded and made executable."

echo "Downloading integrations latest.apk..."
wget -q -O "$SCRIPT_DIR/integrations.apk" "$integrations_apk_url"
echo "integrations.apk downloaded successfully."

# --- Download or verify revanced-cli jar ---
CLI_JAR="$SCRIPT_DIR/cli.jar"
EXPECTED_CLI_SIZE=50856316

if [ -f "$CLI_JAR" ]; then
  ACTUAL_CLI_SIZE=$(stat -c%s "$CLI_JAR")
  if [ "$ACTUAL_CLI_SIZE" -eq "$EXPECTED_CLI_SIZE" ]; then
    echo "cli.jar already present with correct size, skipping download."
  else
    echo "cli.jar size mismatch (expected $EXPECTED_CLI_SIZE, got $ACTUAL_CLI_SIZE). Downloading fresh copy..."
    wget -q -O "$CLI_JAR" https://github.com/ReVanced/revanced-cli/releases/download/v4.6.0/revanced-cli-4.6.0-all.jar
    chmod 0755 "$CLI_JAR"
  fi
else
  echo "cli.jar not found, downloading..."
  wget -q -O "$CLI_JAR" https://github.com/ReVanced/revanced-cli/releases/download/v4.6.0/revanced-cli-4.6.0-all.jar
  chmod 0755 "$CLI_JAR"
fi

# --- Prepare Input APK for Patching ---
echo "Lubing up Twitter.apk for penetration..."
if [ ! -f "$SCRIPT_DIR/Twitter.apk" ]; then
  echo "Error: Original Twitter.apk not found in the current directory. Are you retarded?."
  exit 1
fi

cp "$SCRIPT_DIR/Twitter.apk" "$SCRIPT_DIR/patched_Twitter.apk"

echo "Create dummy options.json"
cat > "$SCRIPT_DIR/options.json" << EOF
[
  { "patchName": "Add ability to copy media link", "options": [] },
  { "patchName": "Bring back twitter", "options": [] },
  { "patchName": "Clear tracking params", "options": [] },
  { "patchName": "Control video auto scroll", "options": [] },
  { "patchName": "Custom download folder", "options": [] },
  { "patchName": "Custom downloader", "options": [] },
  { "patchName": "Custom sharing domain", "options": [] },
  { "patchName": "Custom translator", "options": [] },
  { "patchName": "Customise post font size", "options": [] },
  { "patchName": "Customize Inline action Bar items", "options": [] },
  { "patchName": "Customize Navigation Bar items", "options": [] },
  { "patchName": "Customize explore tabs", "options": [] },
  { "patchName": "Customize profile tabs", "options": [] },
  { "patchName": "Customize reply sort filter", "options": [] },
  { "patchName": "Customize search suggestions", "options": [] },
  { "patchName": "Customize search tab items", "options": [] },
  { "patchName": "Customize side bar items", "options": [] },
  { "patchName": "Customize timeline top bar", "options": [] },
  { "patchName": "Delete from database", "options": [] },
  { "patchName": "Disable auto timeline scroll on launch", "options": [] },
  { "patchName": "Disable chirp font", "options": [] },
  { "patchName": "Download patch", "options": [] },
  { "patchName": "Dynamic color", "options": [] },
  { "patchName": "Enable PiP mode automatically", "options": [] },
  { "patchName": "Enable Reader Mode", "options": [] },
  { "patchName": "Enable Undo Posts", "options": [] },
  { "patchName": "Enable app icons", "options": [] },
  { "patchName": "Enable debug menu for posts", "options": [] },
  { "patchName": "Enable force HD videos", "options": [] },
  { "patchName": "Force enable translate", "options": [] },
  { "patchName": "Handle custom twitter links", "options": [] },
  { "patchName": "Hide Banner", "options": [] },
  { "patchName": "Hide Community Notes", "options": [] },
  { "patchName": "Hide FAB", "options": [] },
  { "patchName": "Hide FAB Menu Buttons", "options": [] },
  { "patchName": "Hide Live Threads", "options": [] },
  { "patchName": "Hide Promoted Trends", "options": [] },
  { "patchName": "Hide Recommended Users", "options": [] },
  { "patchName": "Hide bookmark icon in timeline", "options": [] },
  { "patchName": "Hide community badges", "options": [] },
  { "patchName": "Hide followed by context", "options": [] },
  { "patchName": "Hide hidden replies", "options": [] },
  { "patchName": "Hide immersive player", "options": [] },
  { "patchName": "Hide nudge button", "options": [] },
  { "patchName": "Hide promote button", "options": [] },
  { "patchName": "Hook feature flag", "options": [] },
  { "patchName": "Log server response", "options": [] },
  { "patchName": "No shortened URL", "options": [] },
  { "patchName": "Remove \"Communities to join\" Banner", "options": [] },
  { "patchName": "Remove \"Creators to subscribe\" Banner", "options": [] },
  { "patchName": "Remove \"Pinned posts by followers\" Banner", "options": [] },
  { "patchName": "Remove \"Revisit Bookmark\" Banner", "options": [] },
  { "patchName": "Remove \"Today's News\"", "options": [] },
  { "patchName": "Remove \"Who to follow\" Banner", "options": [] },
  { "patchName": "Remove Ads", "options": [] },
  { "patchName": "Remove Detailed posts", "options": [] },
  { "patchName": "Remove Google Ads", "options": [] },
  { "patchName": "Remove main event", "options": [] },
  { "patchName": "Remove message prompts Banner", "options": [] },
  { "patchName": "Remove premium upsell", "options": [] },
  { "patchName": "Remove superhero event", "options": [] },
  { "patchName": "Remove top people in search", "options": [] },
  { "patchName": "Remove videos for you", "options": [] },
  { "patchName": "Remove view count", "options": [] },
  { "patchName": "Round off numbers", "options": [] },
  { "patchName": "Selectable Text", "options": [] },
  { "patchName": "Show poll results", "options": [] },
  { "patchName": "Show post source label", "options": [] },
  { "patchName": "Show sensitive media", "options": [] }
]
EOF

# --- Do the patching ---
echo -n "Change Icon old Twitter blue (you have 15s to decide or I'm ganking it) (y/n) [default: y]: "
read -r -t 15 change_icon || change_icon="y"

echo "Starting patching process..."
if [[ "$change_icon" =~ ^[Yy]$ ]]; then
  java -jar "$CLI_JAR" patch \
    --options "$SCRIPT_DIR/options.json" \
    --custom-aapt2-binary "$SCRIPT_DIR/aapt2" \
    --patch-bundle "$SCRIPT_DIR/piko.jar" \
    --include "Bring back twitter" \
    -m "$SCRIPT_DIR/integrations.apk" \
    -o "$SCRIPT_DIR/PikoX.apk" \
    "$SCRIPT_DIR/patched_Twitter.apk"
else
  java -jar "$CLI_JAR" patch \
    --options "$SCRIPT_DIR/options.json" \
    --custom-aapt2-binary "$SCRIPT_DIR/aapt2" \
    --patch-bundle "$SCRIPT_DIR/piko.jar" \
    -m "$SCRIPT_DIR/integrations.apk" \
    -o "$SCRIPT_DIR/PikoX.apk" \
    "$SCRIPT_DIR/patched_Twitter.apk"
fi

echo "Patching command executed. Checking for PikoX.apk..."

if [ -f "$SCRIPT_DIR/PikoX.apk" ]; then
  echo "Patch success, Resinous penetrated Twitter saved to PikoX.apk"
else
  echo "Warning: PikoX.apk not found after patching. The patching process might have failed. Please check the output above for errors."
fi

echo "Resinous Twitter deluxe up in yo box peace"
