#!/usr/bin/env bash
set -euo pipefail

# Local signed & notarized release for Americano.
#
# All credentials stay in this machine's Keychain — nothing is uploaded to
# GitHub Secrets. One-time setup:
#
#   1. Xcode → Settings → Accounts → Manage Certificates → "+" →
#      "Developer ID Application" (Account Holder only).
#   2. App Store Connect → Users and Access → Integrations → App Store
#      Connect API → create a key (Developer role), then:
#        xcrun notarytool store-credentials "americano-notary" \
#          --key /path/to/AuthKey_XXXXXXXXXX.p8 \
#          --key-id XXXXXXXXXX --issuer XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX
#   3. gh auth login  (used for `gh release` and the homebrew-tap push)
#   4. Sparkle EdDSA private key must be in the login keychain (it already is
#      if `generate_keys` ran on this machine); otherwise export
#      SPARKLE_PRIVATE_KEY_FILE=/path/to/key before running.
#
# Usage: bash Scripts/release-local.sh

PROJECT_NAME="Americano"
APP_NAME="${PROJECT_NAME}.app"
ARCHIVE_NAME="${PROJECT_NAME}.xcarchive"
RELEASE_FOLDER="Releases"
TAP_REPO_SLUG="LZhenHong/homebrew-tap"
NOTARY_PROFILE="${NOTARY_KEYCHAIN_PROFILE:-americano-notary}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${SCRIPT_DIR}/.." || exit 1

fail() { echo "[!] $*" >&2; exit 1; }

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "${TMP_DIR}"' EXIT

# --- Preflight ---------------------------------------------------------------

echo "[*] preflight checks."

BRANCH="$(git branch --show-current)"
[[ "${BRANCH}" == "main" ]] || fail "releases must run on main (current: ${BRANCH})."

IDENTITY_LINE="$(security find-identity -v -p codesigning | grep "Developer ID Application" | head -1 || true)"
[[ -n "${IDENTITY_LINE}" ]] || fail "no Developer ID Application certificate in Keychain.
    Create one: Xcode → Settings → Accounts → Manage Certificates → '+' → Developer ID Application."
TEAM_ID="$(echo "${IDENTITY_LINE}" | grep -oE '\([A-Z0-9]{10}\)' | tail -1 | tr -d '()')"
echo "    identity: $(echo "${IDENTITY_LINE}" | sed -E 's/^[[:space:]]*[0-9]+\) [A-F0-9]+ //; s/"//g')"

command -v gh >/dev/null 2>&1 || fail "gh CLI not found (brew install gh)."
gh auth status >/dev/null 2>&1 || fail "gh not authenticated. Run: gh auth login"

xcrun notarytool history --keychain-profile "${NOTARY_PROFILE}" >/dev/null 2>&1 \
    || fail "notarytool keychain profile '${NOTARY_PROFILE}' not found.
    Create it: xcrun notarytool store-credentials \"${NOTARY_PROFILE}\" \\
      --key /path/to/AuthKey_XXXXXXXXXX.p8 --key-id <key-id> --issuer <issuer-uuid>"

if [[ -n "${DEEPSEEK_API_KEY:-}" ]]; then
    command -v jq >/dev/null 2>&1 || fail "jq is required for the AI changelog (brew install jq)."
fi

VERSION="$(awk -F'=' '/^VERSION/ {gsub(/ /,"",$2); print $2}' Americano/Resources/Config.xcconfig)"
[[ -n "${VERSION}" ]] || fail "VERSION not found in Americano/Resources/Config.xcconfig"
TAG="v${VERSION}"

git rev-parse -q --verify "refs/tags/${TAG}" >/dev/null 2>&1 \
    && fail "tag ${TAG} already exists locally. Bump VERSION in Config.xcconfig before re-running."
git ls-remote --exit-code --tags origin "refs/tags/${TAG}" >/dev/null 2>&1 \
    && fail "tag ${TAG} already exists on origin. Bump VERSION in Config.xcconfig before re-running."

echo "    version: ${VERSION}"

# --- Changelog ---------------------------------------------------------------

mkdir -p "${RELEASE_FOLDER}"

if [[ "${SKIP_CHANGELOG:-0}" == "1" ]]; then
    echo "[*] SKIP_CHANGELOG=1; using existing release notes in ${RELEASE_FOLDER}/."
    [[ -f "${RELEASE_FOLDER}/${APP_NAME}.html" && -f "${RELEASE_FOLDER}/CHANGELOG.md" ]] \
        || fail "SKIP_CHANGELOG=1 but ${RELEASE_FOLDER}/${APP_NAME}.html or ${RELEASE_FOLDER}/CHANGELOG.md is missing."
elif [[ -n "${DEEPSEEK_API_KEY:-}" ]]; then
    echo "[*] generating AI changelog."
    bash Scripts/changelog.sh
else
    echo "[*] DEEPSEEK_API_KEY not set; using plain git-log changelog."
    PREV_REF="$(git describe --tags --abbrev=0 2>/dev/null || git rev-list --max-parents=0 HEAD)"
    if [[ "${PREV_REF}" =~ ^[0-9a-f]{40}$ ]]; then
        COMMITS="$(git log --pretty=format:"- %s" --no-merges)"
    else
        COMMITS="$(git log "${PREV_REF}"..HEAD --pretty=format:"- %s" --no-merges)"
    fi
    [[ -n "${COMMITS}" ]] || fail "no commits since ${PREV_REF} — nothing to release."

    {
        echo "<h2>Version ${VERSION}</h2>"
        echo "<ul>"
        echo "${COMMITS}" | sed -e 's/&/\&amp;/g' -e 's/</\&lt;/g' -e 's/^- \(.*\)$/<li>\1<\/li>/'
        echo "</ul>"
    } > "${RELEASE_FOLDER}/${APP_NAME}.html"
    printf '# %s %s\n\n%s\n' "${PROJECT_NAME}" "${TAG}" "${COMMITS}" > "${RELEASE_FOLDER}/CHANGELOG.md"
fi

# --- Build (signed) ----------------------------------------------------------

echo "[*] archiving (this bumps the build number via the scheme pre-action)."
rm -rf "${ARCHIVE_NAME}"

xcodebuild archive \
    -scheme "${PROJECT_NAME}" \
    -derivedDataPath Build \
    -configuration Release \
    -destination 'platform=macOS' \
    -archivePath "${ARCHIVE_NAME}" \
    -skipMacroValidation \
    ENABLE_HARDENED_RUNTIME=YES

# --- Export with Developer ID ------------------------------------------------

echo "[*] exporting with Developer ID (team ${TEAM_ID})."

cat > "${TMP_DIR}/ExportOptions.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>developer-id</string>
    <key>teamID</key>
    <string>${TEAM_ID}</string>
    <key>signingStyle</key>
    <string>automatic</string>
</dict>
</plist>
EOF

EXPORT_DIR="${TMP_DIR}/export"
xcodebuild -exportArchive \
    -archivePath "${ARCHIVE_NAME}" \
    -exportPath "${EXPORT_DIR}" \
    -exportOptionsPlist "${TMP_DIR}/ExportOptions.plist"

APP_PATH="${EXPORT_DIR}/${APP_NAME}"
[[ -d "${APP_PATH}" ]] || fail "export did not produce ${APP_NAME}."

echo "[*] verifying signature."
codesign --verify --deep --strict --verbose=2 "${APP_PATH}"
codesign -dv --verbose=4 "${APP_PATH}" 2>&1 | grep -q "flags=.*runtime" \
    || fail "hardened runtime flag missing on ${APP_NAME}."
codesign -dv --verbose=4 "${APP_PATH}" 2>&1 | grep -q "Authority=Developer ID Application" \
    || fail "${APP_NAME} is not signed with a Developer ID certificate."

# --- Notarize ----------------------------------------------------------------

echo "[*] notarizing (usually takes 1-5 minutes)."
NOTARY_ZIP="${TMP_DIR}/${APP_NAME}.zip"
ditto -c -k --keepParent "${APP_PATH}" "${NOTARY_ZIP}"
xcrun notarytool submit "${NOTARY_ZIP}" --keychain-profile "${NOTARY_PROFILE}" --wait
xcrun stapler staple "${APP_PATH}"

echo "[*] gatekeeper assessment."
spctl -a -vv "${APP_PATH}"

# --- Package -----------------------------------------------------------------

echo "[*] packing release zip."
# Remove stale zips so generate_appcast only picks up the current build.
rm -f "${RELEASE_FOLDER}"/*.app.zip
ditto -c -k --keepParent "${APP_PATH}" "${RELEASE_FOLDER}/${APP_NAME}.zip"

# --- Appcast -----------------------------------------------------------------

echo "[*] generating appcast."
bash Scripts/gen-appcast.sh

# --- Commit, tag, push --------------------------------------------------------

echo "[*] committing appcast & version."
git add appcast.xml Americano/Resources/Config.xcconfig
if git diff --cached --quiet; then
    echo "    no changes to commit."
else
    git commit -m "[RELEASE] ${TAG}"
fi
git tag -a "${TAG}" -m "Release ${TAG}"
git push --atomic origin HEAD "refs/tags/${TAG}"

# --- GitHub Release ----------------------------------------------------------

echo "[*] creating GitHub release."
gh release create "${TAG}" \
    --title "${PROJECT_NAME} ${TAG}" \
    --notes-file "${RELEASE_FOLDER}/CHANGELOG.md" \
    "${RELEASE_FOLDER}/${APP_NAME}.zip" \
    "${RELEASE_FOLDER}/${APP_NAME}.html" \
    appcast.xml

# --- Homebrew Tap ------------------------------------------------------------

echo "[*] updating homebrew tap."
TAP_DIR="${TMP_DIR}/homebrew-tap"
gh repo clone "${TAP_REPO_SLUG}" "${TAP_DIR}" -- --quiet
bash Scripts/homebrew.sh "${TAP_DIR}"
git -C "${TAP_DIR}" push

echo "[*] done. ${TAG} released."
