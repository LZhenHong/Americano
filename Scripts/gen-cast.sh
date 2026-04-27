#!/usr/bin/env bash
set -euo pipefail

USER_NAME="LZhenHong"
PROJECT_NAME="Americano"
APP_NAME="${PROJECT_NAME}.app"
ARCHIVE_NAME="${PROJECT_NAME}.xcarchive"
RELEASE_FOLDER="./Releases"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${SCRIPT_DIR}/.." || exit 1

export PATH="${PATH}:/opt/homebrew/bin/"
export https_proxy=http://127.0.0.1:6152
export http_proxy=http://127.0.0.1:6152
export all_proxy=socks5://127.0.0.1:6153

echo "[*] preparing..."

pushd "${ARCHIVE_NAME}/Products/Applications/" >/dev/null 2>&1 || {
    echo "Archive not found: ${ARCHIVE_NAME}"
    exit 1
}

VERSION="$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" "${APP_NAME}/Contents/Info.plist")"
popd >/dev/null 2>&1

echo "[*] version: ${VERSION}"

GEN_PATH="./Build/SourcePackages/artifacts/sparkle/Sparkle/bin/generate_appcast"

if [[ -f "${GEN_PATH}" ]]; then
    chmod +x "${GEN_PATH}" || echo "[*] generate_appcast chmod failed."

    APPCAST_FILE="./appcast.xml"
    DOWNLOAD_PREFIX="https://github.com/${USER_NAME}/${PROJECT_NAME}/releases/download/v${VERSION}/"

    "${GEN_PATH}" -o "${APPCAST_FILE}" --download-url-prefix "${DOWNLOAD_PREFIX}" "${RELEASE_FOLDER}"
else
    echo "[*] generate_appcast not found."
fi

git add appcast.xml
git commit -m "[UPDATE] Version ${VERSION}." || true
git tag -a "v${VERSION}" -m "Version ${VERSION}." || true

echo "[*] done.
