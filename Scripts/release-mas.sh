#!/usr/bin/env bash
set -euo pipefail

# Mac App Store release lane for Americano: archives the AmericanoMAS target
# and uploads the build to App Store Connect.
#
# All credentials stay on this machine. One-time setup:
#
#   1. App Store Connect: create the app record for io.lzhlovesjyq.Americano
#      (category: Utilities; privacy: no data collected).
#   2. Keychain: an "Apple Distribution" certificate
#      (Xcode → Settings → Accounts → Manage Certificates → "+" → Apple Distribution).
#   3. App Store Connect API key — the same AuthKey used for notarization:
#        export ASC_KEY_ID=<key-id>
#        export ASC_ISSUER_ID=<issuer-uuid>
#        export ASC_KEY_PATH=/path/to/AuthKey_XXXXXXXXXX.p8
#
# This script only uploads a build. Metadata, screenshots, and submitting for
# review happen manually in App Store Connect. Tags, GitHub Releases,
# appcast.xml, and the Homebrew cask are owned by Scripts/release-local.sh.
#
# Usage: bash Scripts/release-mas.sh

PROJECT_NAME="Americano"
SCHEME_NAME="AmericanoMAS"
ARCHIVE_NAME="${SCHEME_NAME}.xcarchive"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${SCRIPT_DIR}/.." || exit 1

fail() { echo "[!] $*" >&2; exit 1; }

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "${TMP_DIR}"' EXIT

# --- Preflight ---------------------------------------------------------------

echo "[*] preflight checks."

BRANCH="$(git branch --show-current)"
[[ "${BRANCH}" == "main" ]] || fail "releases must run on main (current: ${BRANCH})."

[[ -z "$(git status --porcelain)" ]] || fail "working tree is dirty; commit or stash first."

security find-identity -v -p codesigning | grep -q "Apple Distribution" \
    || fail "no Apple Distribution certificate in Keychain.
    Create one: Xcode → Settings → Accounts → Manage Certificates → '+' → Apple Distribution."

: "${ASC_KEY_ID:?set ASC_KEY_ID (App Store Connect API key id)}"
: "${ASC_ISSUER_ID:?set ASC_ISSUER_ID (App Store Connect issuer uuid)}"
: "${ASC_KEY_PATH:?set ASC_KEY_PATH (path to AuthKey_XXXXXXXXXX.p8)}"
[[ -f "${ASC_KEY_PATH}" ]] || fail "ASC_KEY_PATH does not exist: ${ASC_KEY_PATH}"

VERSION="$(awk -F'=' '/^VERSION/ {gsub(/ /,"",$2); print $2}' "${PROJECT_NAME}/Resources/Config.xcconfig")"
[[ -n "${VERSION}" ]] || fail "VERSION not found in ${PROJECT_NAME}/Resources/Config.xcconfig"
echo "    version: ${VERSION} (build number auto-bumps via the scheme pre-action)"

# --- Archive -----------------------------------------------------------------

echo "[*] archiving ${SCHEME_NAME} (Release)."
rm -rf "${ARCHIVE_NAME}"

xcodebuild archive \
    -scheme "${SCHEME_NAME}" \
    -derivedDataPath Build \
    -configuration Release \
    -destination 'platform=macOS' \
    -archivePath "${ARCHIVE_NAME}" \
    -skipMacroValidation \
    -allowProvisioningUpdates \
    -authenticationKeyPath "${ASC_KEY_PATH}" \
    -authenticationKeyID "${ASC_KEY_ID}" \
    -authenticationKeyIssuerID "${ASC_ISSUER_ID}"

# --- Export & upload ----------------------------------------------------------

echo "[*] exporting and uploading to App Store Connect."

cat > "${TMP_DIR}/ExportOptions.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>app-store-connect</string>
    <key>destination</key>
    <string>upload</string>
    <key>signingStyle</key>
    <string>automatic</string>
</dict>
</plist>
EOF

xcodebuild -exportArchive \
    -archivePath "${ARCHIVE_NAME}" \
    -exportPath "${TMP_DIR}/export" \
    -exportOptionsPlist "${TMP_DIR}/ExportOptions.plist" \
    -allowProvisioningUpdates \
    -authenticationKeyPath "${ASC_KEY_PATH}" \
    -authenticationKeyID "${ASC_KEY_ID}" \
    -authenticationKeyIssuerID "${ASC_ISSUER_ID}"

echo "[*] done. ${SCHEME_NAME} ${VERSION} uploaded to App Store Connect."
echo "    next: App Store Connect → metadata/screenshots → submit for review (manual)."
