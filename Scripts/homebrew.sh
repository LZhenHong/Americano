#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$(dirname "$SCRIPT_DIR")" || exit 1

PROJECT_NAME="Americano"
USER_NAME="LZhenHong"
BUNDLE_ID="io.lzhlovesjyq.Americano"
RELEASE_FOLDER="Releases"

if [[ -z "${1:-}" ]]; then
    echo "Usage: $0 <tap_repo_path>"
    exit 1
fi

TAP_REPO="$1"
if [[ ! -d "$TAP_REPO" ]]; then
    echo "Error: Tap repo not found: $TAP_REPO"
    exit 1
fi

VERSION=$(xcodebuild -project "${PROJECT_NAME}.xcodeproj" -showBuildSettings -scheme "${PROJECT_NAME}" 2>/dev/null | grep "MARKETING_VERSION" | head -1 | awk '{print $3}')
if [[ -z "$VERSION" ]]; then
    echo "Error: failed to read MARKETING_VERSION from xcodebuild"
    exit 1
fi

ZIP_PATH="${RELEASE_FOLDER}/${PROJECT_NAME}.app.zip"
if [[ ! -f "$ZIP_PATH" ]]; then
    echo "Error: ZIP not found: $ZIP_PATH"
    exit 1
fi

SHA256=$(shasum -a 256 "$ZIP_PATH" | awk '{print $1}')
if [[ -z "$SHA256" ]]; then
    echo "Error: failed to compute SHA256 of $ZIP_PATH"
    exit 1
fi

echo "Version: $VERSION"
echo "SHA256:  $SHA256"

mkdir -p "$TAP_REPO/Casks"
cat > "$TAP_REPO/Casks/americano.rb" << EOF
cask "americano" do
  version "$VERSION"
  sha256 "$SHA256"

  url "https://github.com/${USER_NAME}/${PROJECT_NAME}/releases/download/v#{version}/${PROJECT_NAME}.app.zip"
  name "Americano"
  desc "Prevent your Mac from sleeping"
  homepage "https://github.com/${USER_NAME}/${PROJECT_NAME}"

  depends_on macos: ">= :sonoma"

  app "${PROJECT_NAME}.app"

  postflight do
    system_command "/usr/bin/xattr",
                   args: ["-cr", "#{appdir}/${PROJECT_NAME}.app"],
                   sudo: false
  end

  zap trash: [
    "~/Library/Preferences/${BUNDLE_ID}.plist",
  ]
end
EOF

echo "Updated: $TAP_REPO/Casks/americano.rb"

cd "$TAP_REPO"
if [[ -n $(git status --porcelain) ]]; then
    git config user.name "github-actions[bot]"
    git config user.email "github-actions[bot]@users.noreply.github.com"
    git add -A
    git commit -m "Update Americano to $VERSION"
    echo "Committed changes"
else
    echo "No changes to commit"
fi
