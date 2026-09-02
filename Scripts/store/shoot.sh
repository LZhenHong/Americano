#!/usr/bin/env bash
# Capture raw window screenshots for one locale (onboarding + settings tabs).
# Usage: shoot.sh <locale> <durationsTabName> <batteryTabName>
# Requires: Debug build with -showSettings hook (see AppDelegate), Screen Recording
# and Accessibility permission for the calling terminal.
set -euo pipefail

LOCALE="$1"; DUR_TAB="$2"; BAT_TAB="$3"
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
DBG="$ROOT/Build/Build/Products/Debug/Americano.app"
RAW="$ROOT/Store/screenshots/raw/$LOCALE"
BUNDLE_ID="io.lzhlovesjyq.Americano"
mkdir -p "$RAW"

pkill -f "Products/Debug/Americano" 2>/dev/null || true
sleep 1
# -showSettings: DEBUG hook to open the Settings window at launch.
# -io.lzhlovesjyq.appstate.hasseenonboarding 0: argument-domain override so the
# onboarding window appears (the @storage macro key is prefixed + lowercased).
# -NSRequiresAquaSystemAppearance YES: force light appearance (launch-arg domain
# is the only one a sandboxed app reads reliably).
open -n "$DBG" --args -AppleLanguages "(${LOCALE})" -showSettings -NSRequiresAquaSystemAppearance YES -io.lzhlovesjyq.appstate.hasseenonboarding 0
sleep 3

PID=$(pgrep -n -f "Products/Debug/Americano")
echo "locale=${LOCALE} pid=${PID}"

# Move all app windows onto the built-in Retina display for 2x captures.
AXMV="tell application \"System Events\" to tell (first process whose bundle identifier is \"${BUNDLE_ID}\")"
osascript -e "${AXMV} to repeat with w in windows
    set position of w to {-1000, 800}
  end repeat" 2>/dev/null || true
sleep 1

swift "$ROOT/Scripts/store/list.swift" "$PID" | tee "$RAW/windows.txt"

# Identify windows: onboarding is 440x528; settings is the layer-0 window that isn't.
ONB_ID=$(awk -F'\t' '$3 ~ /440x528/ {print $1}' "$RAW/windows.txt" | head -1)
SET_ID=$(awk -F'\t' '$2 == "layer=0" && $3 !~ /440x528/ {print $1}' "$RAW/windows.txt" | head -1)
echo "onboarding=${ONB_ID:-none} settings=${SET_ID:-none}"

if [[ -n "${ONB_ID}" ]]; then
  screencapture -o -l"${ONB_ID}" "$RAW/onboarding.png"
else
  echo "WARN: no onboarding window found"
fi
[[ -z "${SET_ID}" ]] && { echo "ERROR: no settings window"; exit 1; }

screencapture -o -l"${SET_ID}" "$RAW/general.png"

AX="tell application \"System Events\" to tell (first process whose bundle identifier is \"${BUNDLE_ID}\")"
osascript -e "${AX} to click button \"${DUR_TAB}\" of toolbar 1 of (first window whose name is not \"\")" 2>/dev/null || \
osascript -e "${AX} to click button \"${DUR_TAB}\" of toolbar 1 of window 2"
sleep 1
screencapture -o -l"${SET_ID}" "$RAW/durations.png"

osascript -e "${AX} to click button \"${BAT_TAB}\" of toolbar 1 of window 2" 2>/dev/null || \
osascript -e "${AX} to click button \"${BAT_TAB}\" of toolbar 1 of (first window whose name is not \"\")"
sleep 1
screencapture -o -l"${SET_ID}" "$RAW/battery.png"

echo "done ${LOCALE}"
