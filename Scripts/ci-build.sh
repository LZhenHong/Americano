#!/usr/bin/env bash
set -euo pipefail

PROJECT_NAME="Americano"
RELEASE_FOLDER="Releases"
APP_NAME="${PROJECT_NAME}.app"
ARCHIVE_NAME="${PROJECT_NAME}.xcarchive"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${SCRIPT_DIR}/.." || exit 1

mkdir -p "${RELEASE_FOLDER}"

rm -rf Build Archive *.xcarchive || true

echo "[*] start build."

xcodebuild archive \
    -scheme "${PROJECT_NAME}" \
    -derivedDataPath Build \
    -configuration Release \
    -destination 'platform=macOS' \
    -archivePath "${ARCHIVE_NAME}" \
    clean archive \
    CODE_SIGNING_ALLOWED=NO

TARGET_DIR="${PWD}/${RELEASE_FOLDER}"
if [[ $# -gt 0 && -n "$1" ]]; then
    TARGET_DIR="$1"
fi

pushd "${ARCHIVE_NAME}/Products/Applications/" >/dev/null 2>&1
zip -r "${TARGET_DIR}/${APP_NAME}.zip" "${APP_NAME}"
popd >/dev/null 2>&1

echo "[*] done build."
