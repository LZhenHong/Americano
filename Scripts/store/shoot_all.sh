#!/usr/bin/env bash
# Capture raw screenshots for all store locales.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

"$ROOT/Scripts/store/shoot.sh" en-US Durations Battery
"$ROOT/Scripts/store/shoot.sh" zh-Hans 时长 电池
"$ROOT/Scripts/store/shoot.sh" zh-Hant 時長 電池

pkill -f "Products/Debug/Americano" 2>/dev/null || true
echo "all locales captured"
