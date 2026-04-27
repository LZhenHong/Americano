#!/usr/bin/env bash
set -euo pipefail

# Bump build number (and optionally version) in Config.xcconfig.
# Intended to run as an Xcode pre-action or standalone.

if [[ -n "${SRCROOT:-}" && -n "${PRODUCT_NAME:-}" ]]; then
    cd "${SRCROOT}/${PRODUCT_NAME}/Resources" || exit 1
else
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    cd "${SCRIPT_DIR}/../Americano/Resources" || exit 1
fi

FILE_NAME="Config.xcconfig"

increase_build_number() {
    local previous_build
    previous_build="$(awk -F "=" '/BUILD_NUMBER/ {print $2}' "${FILE_NAME}" | tr -d ' ')"

    local current_date
    current_date="$(date "+%Y%m%d")"

    local previous_date="${previous_build:0:8}"
    local counter="${previous_build:8}"

    local new_counter
    if [[ "${current_date}" == "${previous_date}" ]]; then
        new_counter=$((counter + 1))
    else
        new_counter=1
    fi

    local counter_suffix
    counter_suffix="$(printf "%03d" "${new_counter}")"

    local new_build="${current_date}${counter_suffix}"

    sed -i -e "/BUILD_NUMBER =/ s/= .*/= ${new_build}/" "${FILE_NAME}"
    rm -f "${FILE_NAME}-e"

    echo "Bumped Build Number: ${new_build}"
}

increase_version() {
    local version
    version="$(awk -F "=" '/VERSION/ {print $2}' "${FILE_NAME}" | tr -d ' ')"
    echo "Previous Version: ${version}"

    local major minor patch
    major="$(echo "${version}" | cut -d. -f1)"
    minor="$(echo "${version}" | cut -d. -f2)"
    patch="$(echo "${version}" | cut -d. -f3)"

    local configuration="${CONFIGURATION:-}"
    if [[ "${configuration}" == "Release" ]]; then
        patch=$((patch + 1))
    fi

    local new_version="${major}.${minor}.${patch}"

    sed -i -e "/VERSION =/ s/= .*/= ${new_version}/" "${FILE_NAME}"
    rm -f "${FILE_NAME}-e"

    echo "Bumped Version: ${new_version}"
}

increase_build_number

bump=false
if [[ "${BUMP_VERSION:-}" == "1" ]]; then
    bump=true
fi

if [[ "${bump}" == true ]]; then
    increase_version
else
    echo "Skipping version bump"
fi
