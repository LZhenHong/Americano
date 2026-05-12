#!/usr/bin/env bash
set -euo pipefail

USER_NAME="LZhenHong"
PROJECT_NAME="Americano"
APP_NAME="${PROJECT_NAME}.app"
ARCHIVE_NAME="${PROJECT_NAME}.xcarchive"
RELEASE_FOLDER="./Releases"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${SCRIPT_DIR}/.." || exit 1

echo "[*] preparing..."

pushd "${ARCHIVE_NAME}/Products/Applications/" >/dev/null 2>&1 || {
    echo "Archive not found: ${ARCHIVE_NAME}"
    exit 1
}

VERSION="$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" "${APP_NAME}/Contents/Info.plist")"
popd >/dev/null 2>&1

echo "[*] version: ${VERSION}"

GEN_PATH="./Build/SourcePackages/artifacts/sparkle/Sparkle/bin/generate_appcast"

if [[ ! -f "${GEN_PATH}" ]]; then
    echo "[!] generate_appcast not found at ${GEN_PATH}"
    echo "    Hint: run Scripts/ci-build.sh first so SPM resolves Sparkle."
    exit 1
fi

chmod +x "${GEN_PATH}" || echo "[*] generate_appcast chmod failed."

APPCAST_FILE="./appcast.xml"
DOWNLOAD_PREFIX="https://github.com/${USER_NAME}/${PROJECT_NAME}/releases/download/v${VERSION}/"

GEN_ARGS=()
if [[ -n "${SPARKLE_PRIVATE_KEY_FILE:-}" && -f "${SPARKLE_PRIVATE_KEY_FILE}" ]]; then
    GEN_ARGS+=(--ed-key-file "${SPARKLE_PRIVATE_KEY_FILE}")
fi

# Bash 3.2 (default macOS bash) errors on "${GEN_ARGS[@]}" when the array is
# empty under `set -u`; the `+` form expands to nothing in that case.
"${GEN_PATH}" -o "${APPCAST_FILE}" --download-url-prefix "${DOWNLOAD_PREFIX}" ${GEN_ARGS[@]+"${GEN_ARGS[@]}"} "${RELEASE_FOLDER}"
echo "[*] appcast generated."

echo "[*] done."
