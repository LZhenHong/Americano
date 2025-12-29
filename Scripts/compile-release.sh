#!/usr/bin/env bash
# Written in [Amber](https://amber-lang.com/)
# version: 0.5.1-alpha
# We cannot import `bash_version` from `env.ab` because it imports `text.ab` making a circular dependency.
# This is a workaround to avoid that issue and the import system should be improved in the future.
dir_exists__36_v0() {
    local path=$1
    [ -d "${path}" ]
    __status=$?
    ret_dir_exists36_v0="$(( ${__status} == 0 ))"
    return 0
}

dir_create__42_v0() {
    local path=$1
    dir_exists__36_v0 "${path}"
    ret_dir_exists36_v0__87_12="${ret_dir_exists36_v0}"
    if [ "$(( ! ${ret_dir_exists36_v0__87_12} ))" != 0 ]; then
        mkdir -p "${path}"
        __status=$?
        if [ "${__status}" != 0 ]; then
            ret_dir_create42_v0=''
            return "${__status}"
        fi
    fi
}

env_var_get__98_v0() {
    local name=$1
    command_0="$(echo ${!name})"
    __status=$?
    if [ "${__status}" != 0 ]; then
        ret_env_var_get98_v0=''
        return "${__status}"
    fi
    ret_env_var_get98_v0="${command_0}"
    return 0
}

printf__106_v0() {
    local format=$1
    local args=("${!2}")
    args=("${format}" "${args[@]}")
    __status=$?
    printf "${args[@]}"
    __status=$?
}

echo_error__116_v0() {
    local message=$1
    local exit_code=$2
    array_1=("${message}")
    printf__106_v0 "\\x1b[1;3;97;41m%s\\x1b[0m
" array_1[@]
    if [ "$(( ${exit_code} > 0 ))" != 0 ]; then
        exit "${exit_code}"
    fi
}

project_name_3="Americano"
release_folder_4="Releases"
app_name_5="${project_name_3}.app"
archive_name_6="${project_name_3}.xcarchive"
env_var_get__98_v0 "PATH"
__status=$?
path_7="${ret_env_var_get98_v0}"
prepare__121_v0() {
    local shell_file=$1
    # $set -e$?
    set -o pipefail
    __status=$?
    if [ "${__status}" != 0 ]; then
        ret_prepare121_v0=''
        return "${__status}"
    fi
    command_2="$(dirname shell_file)"
    __status=$?
    root_dir_9="${command_2}"
    cd "${root_dir_9}/.." || exit
    dir_create__42_v0 "${release_folder_4}"
    __status=$?
    rm -rf Build Archive *.xcarchive *.zip || true
    __status=$?
    export PATH=${path_7}:/opt/homebrew/bin/
    __status=$?
    export https_proxy=http://127.0.0.1:6152;export http_proxy=http://127.0.0.1:6152;export all_proxy=socks5://127.0.0.1:6153
    __status=$?
}

build__122_v0() {
    xcodebuild archive         -scheme ${project_name_3}         -derivedDataPath Build         -configuration Release         -destination 'platform=macOS'         -archivePath ${archive_name_6}         clean archive         CODE_SIGN_IDENTITY="-"         CODE_SIGNING_REQUIRED=YES         CODE_SIGNING_ALLOWED=YES         | xcbeautify
    __status=$?
    if [ "${__status}" != 0 ]; then
        ret_build122_v0=''
        return "${__status}"
    fi
}

extract__123_v0() {
    local target_dir=$1
    pushd ${archive_name_6}/Products/Applications/ >/dev/null 2>&1
    __status=$?
    if [ "${__status}" != 0 ]; then
        ret_extract123_v0=''
        return "${__status}"
    fi
    zip_name_11="${target_dir}/${app_name_5}.zip"
    zip -r ${zip_name_11} ${app_name_5}
    __status=$?
    if [ "${__status}" != 0 ]; then
        ret_extract123_v0=''
        return "${__status}"
    fi
    popd >/dev/null 2>&1
    __status=$?
    if [ "${__status}" != 0 ]; then
        ret_extract123_v0=''
        return "${__status}"
    fi
}

declare -r input_args_8=("$0" "$@")
echo "[*] start build."
prepare__121_v0 "${input_args_8[0]}"
__status=$?
if [ "${__status}" != 0 ]; then
    echo_error__116_v0 "Failed to prepare." "${__status}"
fi
build__122_v0 
__status=$?
if [ "${__status}" != 0 ]; then
    echo_error__116_v0 "Failed to build." "${__status}"
fi
command_4="$(pwd)"
__status=$?
target_dir_10="${command_4}/${release_folder_4}"
__length_5=("${input_args_8[@]}")
__length_6="${input_args_8[1]}"
if [ "$(( $(( ${#__length_5[@]} > 1 )) && $(( ${#__length_6} > 0 )) ))" != 0 ]; then
    target_dir_10="${input_args_8[1]}"
fi
extract__123_v0 "${target_dir_10}"
__status=$?
if [ "${__status}" != 0 ]; then
    echo_error__116_v0 "Failed to extract." "${__status}"
fi
echo "[*] done build."
