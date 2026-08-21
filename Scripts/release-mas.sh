#!/usr/bin/env bash
set -euo pipefail

# Mac App Store release lane for Americano: archives the AmericanoMAS target
# and uploads the build to App Store Connect.
#
# Signing is manual: this team has no access to cloud-managed distribution
# certificates, so Xcode's automatic signing cannot resolve App Store profiles
# ("Cloud signing permission error"). The export pins the certificate and
# profile names below.
#
# All credentials stay on this machine. One-time setup (via the asc CLI with
# the "eden" keychain profile — see ~/.secrets/README.md):
#
#   1. App Store Connect: create the app record for io.lzhlovesjyq.Americano
#      (category: Utilities; privacy: no data collected).
#   2. Certificates, created via `asc certificates create --generate-csr` and
#      imported into the login Keychain:
#        - "Apple Distribution" (DISTRIBUTION) — signs the .app
#        - "3rd Party Mac Developer Installer" (MAC_INSTALLER_DISTRIBUTION) —
#          signs the upload .pkg; this is Apple's CN for installer certs
#   3. Provisioning profile "Americano MAS Store" (MAC_APP_STORE, embedding the
#      Apple Distribution certificate), installed locally. Recreate with:
#        asc profiles create --name "Americano MAS Store" --profile-type MAC_APP_STORE \
#            --bundle <bundle-id-resource-id> --certificate <apple-distribution-cert-id>
#        asc profiles download --id <profile-id> --output AmericanoMAS.provisionprofile
#        cp AmericanoMAS.provisionprofile "$HOME/Library/Developer/Xcode/UserData/Provisioning Profiles/"
#   4. App Store Connect API key in the environment:
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
TEAM_ID="ND2HQQ895Z"
PROFILE_NAME="Americano MAS Store"

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
    || fail "no Apple Distribution certificate in Keychain (see header for the asc-based setup)."

security find-identity -v -p basic | grep -q "3rd Party Mac Developer Installer" \
    || fail "no Mac installer certificate in Keychain (\"3rd Party Mac Developer Installer\"; see header)."

# A valid App Store profile must already be installed locally: automatic
# signing cannot create one without cloud-managed certificate access.
store_profile_valid() {
    local dir file name exp exp_ts
    for dir in \
        "${HOME}/Library/Developer/Xcode/UserData/Provisioning Profiles" \
        "${HOME}/Library/MobileDevice/Provisioning Profiles"; do
        [[ -d "${dir}" ]] || continue
        for file in "${dir}"/*.provisionprofile; do
            [[ -e "${file}" ]] || continue
            name="$(security cms -D -i "${file}" 2>/dev/null | plutil -extract Name raw -o - - 2>/dev/null)" || continue
            [[ "${name}" == "${PROFILE_NAME}" ]] || continue
            exp="$(security cms -D -i "${file}" 2>/dev/null | plutil -extract ExpirationDate raw -o - - 2>/dev/null)" || continue
            exp_ts="$(date -j -f '%Y-%m-%dT%H:%M:%SZ' "${exp}" '+%s' 2>/dev/null || echo 0)"
            [[ "${exp_ts}" -gt "$(date '+%s')" ]] && return 0
        done
    done
    return 1
}

store_profile_valid \
    || fail "provisioning profile \"${PROFILE_NAME}\" missing or expired; recreate it via asc (see header)."

: "${ASC_KEY_ID:?set ASC_KEY_ID (App Store Connect API key id)}"
: "${ASC_ISSUER_ID:?set ASC_ISSUER_ID (App Store Connect issuer uuid)}"
: "${ASC_KEY_PATH:?set ASC_KEY_PATH (path to AuthKey_XXXXXXXXXX.p8)}"
[[ -f "${ASC_KEY_PATH}" ]] || fail "ASC_KEY_PATH does not exist: ${ASC_KEY_PATH}"

VERSION="$(awk -F'=' '/^VERSION/ {gsub(/ /,"",$2); print $2}' "${PROJECT_NAME}/Resources/Config.xcconfig")"
[[ -n "${VERSION}" ]] || fail "VERSION not found in ${PROJECT_NAME}/Resources/Config.xcconfig"
echo "    version: ${VERSION} (build number auto-bumps via the scheme pre-action)"

BUNDLE_ID="$(awk -F'=' '/^BUNDLE_IDENTIFIER/ {gsub(/ /,"",$2); print $2}' "${PROJECT_NAME}/Resources/Config.xcconfig")"
[[ -n "${BUNDLE_ID}" ]] || fail "BUNDLE_IDENTIFIER not found in ${PROJECT_NAME}/Resources/Config.xcconfig"

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
    <string>manual</string>
    <key>teamID</key>
    <string>${TEAM_ID}</string>
    <key>signingCertificate</key>
    <string>Apple Distribution</string>
    <key>provisioningProfiles</key>
    <dict>
        <key>${BUNDLE_ID}</key>
        <string>${PROFILE_NAME}</string>
    </dict>
    <key>installerSigningCertificate</key>
    <string>3rd Party Mac Developer Installer</string>
</dict>
</plist>
EOF

# No -allowProvisioningUpdates here: with manual signing it only triggers
# Xcode's provisioning repair, which removes local profiles it cannot
# re-create without cloud-managed certificate access.
xcodebuild -exportArchive \
    -archivePath "${ARCHIVE_NAME}" \
    -exportPath "${TMP_DIR}/export" \
    -exportOptionsPlist "${TMP_DIR}/ExportOptions.plist" \
    -authenticationKeyPath "${ASC_KEY_PATH}" \
    -authenticationKeyID "${ASC_KEY_ID}" \
    -authenticationKeyIssuerID "${ASC_ISSUER_ID}"

echo "[*] done. ${SCHEME_NAME} ${VERSION} uploaded to App Store Connect."
echo "    next: App Store Connect → metadata/screenshots → submit for review (manual)."
