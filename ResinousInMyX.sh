#!/usr/bin/env bash
set -e # Exit immediately if a command exits with a non-zero status.

# --- Cleanup Previous Files ---
echo "Cleaning up previous run files..."
rm -f piko.rvp integrations.apk patched_Twitter.apk PikoX.apk options.json
# Original Twitter.apk is intentionally NOT removed here to protect it.
echo "Cleanup complete."

# Directory where the script is running
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# --- Check for aapt2 binary ---
if [ ! -f "$SCRIPT_DIR/aapt2" ]; then
  echo "Downloading aapt2 binary..."
  wget -q -O "$SCRIPT_DIR/aapt2" "https://github.com/GhettiGuru/aapt2/releases/download/aapt2/aapt2"
  if [ ! -f "$SCRIPT_DIR/aapt2" ]; then
    echo "Error: You don't have my patcher, you should kill yourself"
    exit 1
  fi
  chmod 0755 "$SCRIPT_DIR/aapt2"
  echo "Resinous patcher extreme online at $SCRIPT_DIR/aapt2"
else
  echo "Resinous patcher extreme online, skipping download."
fi

# --- Download Piko and Integrations ---
echo "Fetching crimera/piko latest release info..."
REPO="crimera/piko"
# Fetch ALL releases instead of just the "latest" stable one
API_URL="https://api.github.com/repos/$REPO/releases"

# Get the JSON for all releases, then select the first one ([0])
release_json=$(wget -q -O - "$API_URL")
rvp_url=$(echo "$release_json" | jq -r '.[0].assets[] | select(.name | endswith(".rvp")) | .browser_download_url')

if [ -z "$rvp_url" ]; then
  echo "Error: Could not find .rvp download URL in the latest release. Exiting."
  exit 1
fi

echo "Downloading piko patches bundle (.rvp)..."
wget -q -O "$SCRIPT_DIR/piko.rvp" "$rvp_url"
if [ ! -f "$SCRIPT_DIR/piko.rvp" ]; then
  echo "Error: piko.rvp not found after download. Exiting."
  exit 1
fi
echo "piko.rvp downloaded successfully."

# --- Download integrations latest.apk ---
echo "Downloading integrations latest.apk..."
wget -q -O "$SCRIPT_DIR/integrations.apk" "$(wget -q -O - https://api.github.com/repos/crimera/revanced-integrations/releases/latest | jq -r '.assets[] | select(.name | endswith(".apk")) | .browser_download_url')"
if [ ! -f "$SCRIPT_DIR/integrations.apk" ]; then
  echo "Error: integrations.apk not found after download. Exiting."
  exit 1
fi
echo "integrations.apk downloaded successfully."

# --- Download or verify revanced-cli jar ---
CLI_JAR="$SCRIPT_DIR/cli.jar"
EXPECTED_CLI_SIZE=41839814 # This is the size for v4.6.0

if [ -f "$CLI_JAR" ]; then
  ACTUAL_CLI_SIZE=$(stat -c%s "$CLI_JAR")
  if [ "$ACTUAL_CLI_SIZE" -eq "$EXPECTED_CLI_SIZE" ]; then
    echo "cli.jar already present with correct size, skipping download."
  else
    echo "cli.jar size mismatch (expected $EXPECTED_CLI_SIZE, got $ACTUAL_CLI_SIZE). Downloading fresh copy..."
    wget -q -O "$CLI_JAR" https://github.com/ReVanced/revanced-cli/releases/download/v5.0.1/revanced-cli-5.0.1-all.jar
  fi
else
  echo "cli.jar not found, downloading..."
  wget -q -O "$CLI_JAR" https://github.com/ReVanced/revanced-cli/releases/download/v4.6.0/revanced-cli-4.6.0-all.jar
fi
chmod 0755 "$CLI_JAR"

# --- Prepare Input APK for Patching ---
echo "Preparing Twitter.apk for patching..."
if [ ! -f "$SCRIPT_DIR/Twitter.apk" ]; then
  echo "Error: Original Twitter.apk not found, are you retarded?"
  exit 1
fi

cp "$SCRIPT_DIR/Twitter.apk" "$SCRIPT_DIR/patched_Twitter.apk"

## create dummy options Json
echo "Creating minimal options.json..."
cat > "$SCRIPT_DIR/options.json" << EOF
[{"name":"Add ability to copy media link","description":null,"compatiblePackages":[{"name":"com.twitter.android","versions":null}],"use":true,"options":[]},{"name":"Bring back twitter","description":"Bring back old twitter logo and name","compatiblePackages":[{"name":"com.twitter.android","versions":null}],"use":true,"options":[]},{"name":"Change version code","description":"Changes the version code of the app. This will turn off app store updates and allows downgrading an existing app install to an older app version.","compatiblePackages":null,"use":true,"options":[{"key":"versionCode","default":2147483647,"values":{"Lowest":1,"Highest":2147483647},"title":"Version code","description":"The version code to use. Using the highest value turns off app store updates and allows downgrading an existing app install to an older app version.","required":true}]},{"name":"Clear tracking params","description":"Removes tracking parameters when sharing links","compatiblePackages":[{"name":"com.twitter.android","versions":null}],"use":true,"options":[]},{"name":"Control video auto scroll","description":"Control video auto scroll in immersive view","compatiblePackages":[{"name":"com.twitter.android","versions":null}],"use":true,"options":[]},{"name":"Custom download folder","description":"Change the download directory for video downloads","compatiblePackages":[{"name":"com.twitter.android","versions":null}],"use":true,"options":[]},{"name":"Custom downloader","description":"Requires X 11.0.0-release.0 or higher.","compatiblePackages":[{"name":"com.twitter.android","versions":null}],"use":true,"options":[]},{"name":"Custom sharing domain","description":"Allows for using domains like fxtwitter when sharing tweets/posts.","compatiblePackages":[{"name":"com.twitter.android","versions":null}],"use":true,"options":[]},{"name":"Custom translator","description":"Requires X 11.0.0-release.0 or higher.","compatiblePackages":[{"name":"com.twitter.android","versions":null}],"use":true,"options":[]},{"name":"Customise post font size","description":null,"compatiblePackages":[{"name":"com.twitter.android","versions":null}],"use":true,"options":[]},{"name":"Customize Inline action Bar items","description":null,"compatiblePackages":[{"name":"com.twitter.android","versions":null}],"use":true,"options":[]},{"name":"Customize Navigation Bar items","description":null,"compatiblePackages":[{"name":"com.twitter.android","versions":null}],"use":true,"options":[]},{"name":"Customize default reply sorting","description":null,"compatiblePackages":[{"name":"com.twitter.android","versions":null}],"use":true,"options":[]},{"name":"Customize explore tabs","description":null,"compatiblePackages":[{"name":"com.twitter.android","versions":null}],"use":true,"options":[]},{"name":"Customize profile tabs","description":null,"compatiblePackages":[{"name":"com.twitter.android","versions":null}],"use":true,"options":[]},{"name":"Customize search suggestions","description":null,"compatiblePackages":[{"name":"com.twitter.android","versions":null}],"use":true,"options":[]},{"name":"Customize search tab items","description":null,"compatiblePackages":[{"name":"com.twitter.android","versions":null}],"use":true,"options":[]},{"name":"Customize side bar items","description":null,"compatiblePackages":[{"name":"com.twitter.android","versions":null}],"use":true,"options":[]},{"name":"Customize timeline top bar","description":null,"compatiblePackages":[{"name":"com.twitter.android","versions":null}],"use":true,"options":[]},{"name":"Delete from database","description":"Delete entries from database(cache)","compatiblePackages":[{"name":"com.twitter.android","versions":null}],"use":true,"options":[]},{"name":"Disable auto timeline scroll on launch","description":null,"compatiblePackages":[{"name":"com.twitter.android","versions":null}],"use":true,"options":[]},{"name":"Disable chirp font","description":null,"compatiblePackages":[{"name":"com.twitter.android","versions":null}],"use":true,"options":[]},{"name":"Download patch","description":"Unlocks the ability to download videos and gifs from Twitter/X","compatiblePackages":[{"name":"com.twitter.android","versions":null}],"use":true,"options":[]},{"name":"Enable PiP mode automatically","description":"Enables PiP mode when you close the app","compatiblePackages":[{"name":"com.twitter.android","versions":null}],"use":true,"options":[]},{"name":"Enable Undo Posts","description":"Enables ability to undo posts before posting","compatiblePackages":[{"name":"com.twitter.android","versions":null}],"use":true,"options":[]},{"name":"Enable debug menu for posts","description":null,"compatiblePackages":[{"name":"com.twitter.android","versions":null}],"use":true,"options":[]},{"name":"Enable force HD videos","description":"Videos will be played in highest quality always","compatiblePackages":[{"name":"com.twitter.android","versions":null}],"use":true,"options":[]},{"name":"Export all activities","description":"Makes all app activities exportable.","compatiblePackages":null,"use":false,"options":[]},{"name":"Force enable translate","description":"Get translate option for all posts","compatiblePackages":[{"name":"com.twitter.android","versions":null}],"use":true,"options":[]},{"name":"Hide Banner","description":"Hide new post banner","compatiblePackages":[{"name":"com.twitter.android","versions":null}],"use":true,"options":[]},{"name":"Hide Community Notes","description":null,"compatiblePackages":[{"name":"com.twitter.android","versions":null}],"use":true,"options":[]},{"name":"Hide FAB","description":"Adds an option to hide Floating action button","compatiblePackages":[{"name":"com.twitter.android","versions":null}],"use":true,"options":[]},{"name":"Hide FAB Menu Buttons","description":null,"compatiblePackages":[{"name":"com.twitter.android","versions":null}],"use":true,"options":[]},{"name":"Hide Live Threads","description":null,"compatiblePackages":[{"name":"com.twitter.android","versions":null}],"use":true,"options":[]},{"name":"Hide Recommended Users","description":"Hide recommended users that pops up when you follow someone","compatiblePackages":[{"name":"com.twitter.android","versions":null}],"use":true,"options":[]},{"name":"Hide bookmark icon in timeline","description":null,"compatiblePackages":[{"name":"com.twitter.android","versions":null}],"use":true,"options":[]},{"name":"Hide community badges","description":null,"compatiblePackages":[{"name":"com.twitter.android","versions":null}],"use":true,"options":[]},{"name":"Hide followed by context","description":"Hides followed by context under profile","compatiblePackages":[{"name":"com.twitter.android","versions":null}],"use":true,"options":[]},{"name":"Hide hidden replies","description":null,"compatiblePackages":[{"name":"com.twitter.android","versions":null}],"use":true,"options":[]},{"name":"Hide immersive player","description":"Removes swipe up for more videos in video player","compatiblePackages":[{"name":"com.twitter.android","versions":null}],"use":true,"options":[]},{"name":"Hide nudge button","description":"Hides follow/subscribe/follow back buttons on posts","compatiblePackages":[{"name":"com.twitter.android","versions":null}],"use":true,"options":[]},{"name":"Hide promote button","description":"Hides promote button under self posts","compatiblePackages":[{"name":"com.twitter.android","versions":null}],"use":true,"options":[]},{"name":"Hide timeline posts by category","description":"Hides different post category like who to follow, news today etc from timeline.","compatiblePackages":[{"name":"com.twitter.android","versions":null}],"use":true,"options":[]},{"name":"Hook feature flag","description":null,"compatiblePackages":[{"name":"com.twitter.android","versions":null}],"use":true,"options":[]},{"name":"Log server response","description":"Log json responses received from server","compatiblePackages":[{"name":"com.twitter.android","versions":null}],"use":true,"options":[]},{"name":"Native reader mode","description":"Requires X 11.0.0-release.0 or higher.","compatiblePackages":[{"name":"com.twitter.android","versions":null}],"use":true,"options":[]},{"name":"No shortened URL","description":"Get rid of t.co short urls.","compatiblePackages":[{"name":"com.twitter.android","versions":null}],"use":true,"options":[]},{"name":"Remove Ads","description":"Removed promoted posts, trends and google ads","compatiblePackages":[{"name":"com.twitter.android","versions":null}],"use":true,"options":[]},{"name":"Remove premium upsell","description":"Removes premium upsell in home timeline","compatiblePackages":[{"name":"com.twitter.android","versions":null}],"use":true,"options":[]},{"name":"Remove view count","description":"Removes the view count from the bottom of tweets","compatiblePackages":[{"name":"com.twitter.android","versions":null}],"use":true,"options":[]},{"name":"Round off numbers","description":"Enable or disable rounding off numbers","compatiblePackages":[{"name":"com.twitter.android","versions":null}],"use":true,"options":[]},{"name":"Selectable Text","description":"Makes bio and username selectable","compatiblePackages":[{"name":"com.twitter.android","versions":null}],"use":true,"options":[]},{"name":"Show poll results","description":"Adds an option to show poll results without voting","compatiblePackages":[{"name":"com.twitter.android","versions":null}],"use":true,"options":[]},{"name":"Show post source label","description":"Source label will be shown only on public posts","compatiblePackages":[{"name":"com.twitter.android","versions":null}],"use":true,"options":[]},{"name":"Show sensitive media","description":null,"compatiblePackages":[{"name":"com.twitter.android","versions":null}],"use":true,"options":[]}]
EOF

# --- Do the patching ---
echo -n "Change icon to the old Twitter blue? You have 15 seconds or I'm ganking it.(y/n) [default: y]: "
read -r -t 15 change_icon || change_icon="y"
echo "Bring back Twitter blue icon patch requires JA/Japanese strings be included for..logistic sushi dependency type reasons"

echo "Starting patching process..."
if [[ "$change_icon" =~ ^[Yy]$ ]]; then
  # By default, all patches are included. We don't need to specify anything extra.
  java -jar "$CLI_JAR" patch \
    --options "$SCRIPT_DIR/options.json" \
    --custom-aapt2-binary "$SCRIPT_DIR/aapt2" \
    --patches "$SCRIPT_DIR/piko.rvp" \
    --force \
    --purge \
    --enable "Bring back twitter" \
    -o "$SCRIPT_DIR/PikoX.apk" \
    "$SCRIPT_DIR/patched_Twitter.apk"
else
  # If 'n', apply all patches EXCEPT for the icon patch.
  java -jar "$CLI_JAR" patch \
    --custom-aapt2-binary "$SCRIPT_DIR/aapt2" \
    --patches "$SCRIPT_DIR/piko.rvp" \
    --force \
    --purge \
    --disable "Bring back twitter" \
    -o "$SCRIPT_DIR/PikoX.apk" \
    "$SCRIPT_DIR/patched_Twitter.apk"
fi

echo "Patching cmds executed."

if [ -f "$SCRIPT_DIR/PikoX.apk" ]; then
  echo "Resinous patches Twitter up in yo box at PikoX.apk"
else
  echo "Warning: PikoX.apk not found. Wtf quit touching yourself as and my options."
fi

echo "Script finished."