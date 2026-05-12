#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${SCRIPT_DIR}/.." || exit 1

PROJECT_NAME="Americano"
RELEASE_FOLDER="Releases"

: "${DEEPSEEK_BASE_URL:=https://api.deepseek.com}"
: "${DEEPSEEK_MODEL:=deepseek-chat}"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info() { echo -e "${BLUE}[INFO]${NC} $1"; }
ok() { echo -e "${GREEN}[OK]${NC} $1"; }
err() { echo -e "${RED}[ERROR]${NC} $1"; }

get_version() {
    xcodebuild -project "${PROJECT_NAME}.xcodeproj" -showBuildSettings -scheme "${PROJECT_NAME}" 2>/dev/null \
        | grep "MARKETING_VERSION" | head -1 | awk '{print $3}'
}

get_previous_ref() {
    git describe --tags --abbrev=0 2>/dev/null || git rev-list --max-parents=0 HEAD
}

get_commits() {
    local ref=$1
    if [[ "$ref" =~ ^[0-9a-f]{40}$ ]]; then
        git log --pretty=format:"- %s" --no-merges
    else
        git log "$ref"..HEAD --pretty=format:"- %s" --no-merges
    fi
}

call_api() {
    local prompt=$1
    local body
    body=$(jq -n --arg m "$DEEPSEEK_MODEL" --arg p "$prompt" \
        '{model:$m, messages:[{role:"user",content:$p}], stream:false}')

    local resp
    resp=$(curl -s "${DEEPSEEK_BASE_URL}/chat/completions" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $DEEPSEEK_API_KEY" \
        -d "$body")

    if echo "$resp" | jq -e '.error' >/dev/null 2>&1; then
        err "API: $(echo "$resp" | jq -r '.error.message // "Unknown"')"
        return 1
    fi
    echo "$resp" | jq -r '.choices[0].message.content // empty'
}

generate_html() {
    local content=$1 version=$2

    call_api "Write release notes for Americano (macOS menu bar app that prevents Mac from sleeping by wrapping the system caffeinate command).

Target: Non-technical end users who only care about what the app DOES, not HOW it works.

INCLUDE (user-visible):
- New features users can see or interact with
- New settings/preferences in the UI
- Changes to app name, icon, or menu bar behavior
- Changes to battery monitoring or auto-stop behavior
- Bug fixes that users would have noticed

EXCLUDE (technical/internal):
- Variable/function/class renames
- Code refactoring
- Memory leaks, performance optimizations (unless dramatic)
- Typo fixes (unless user-visible text)
- CI/CD, build system, documentation changes
- Dependency updates

Git commits since last release:
$content

Format as HTML (for Sparkle appcast <description> tag):
<h2>Version $version</h2>
<h3>✨ New Features</h3>
<ul><li>...</li></ul>
<h3>🔧 Improvements</h3>
<ul><li>...</li></ul>
<h3>🐛 Bug Fixes</h3>
<ul><li>...</li></ul>

Rules:
- Skip empty categories (do not include the heading if no items)
- One sentence per item, plain language
- No <html>, <head>, <body> tags, just the content HTML
- No markdown, pure HTML only
- Describe WHAT changed for users, not code details"
}

main() {
    if [[ -z "${DEEPSEEK_API_KEY:-}" ]]; then
        err "DEEPSEEK_API_KEY not set"
        exit 1
    fi

    local version
    version=$(get_version)
    local prev
    prev=$(get_previous_ref)
    local content
    content=$(get_commits "$prev")

    info "Version: $version"
    info "Generating changelog..."

    local html
    html=$(generate_html "$content" "$version")

    if [[ -z "$html" ]]; then
        err "Failed to generate changelog"
        exit 1
    fi

    mkdir -p "${RELEASE_FOLDER}"

    # Save HTML for appcast
    echo "$html" > "${RELEASE_FOLDER}/release-notes.html"
    ok "Generated: ${RELEASE_FOLDER}/release-notes.html"

    # Convert simple HTML to markdown for GitHub Release body
    local md
    md=$(echo "$html" | sed \
        -e 's/<h2>/## /g' -e 's/<\/h2>//g' \
        -e 's/<h3>/### /g' -e 's/<\/h3>//g' \
        -e 's/<ul>//g' -e 's/<\/ul>//g' \
        -e 's/<li>/- /g' -e 's/<\/li>//g' \
        -e 's/<br>/\n/g' \
        -e 's/<[^>]*>//g')

    echo "$md" > "${RELEASE_FOLDER}/CHANGELOG.md"
    ok "Generated: ${RELEASE_FOLDER}/CHANGELOG.md"
}

main "$@"
