#!/usr/bin/env bash
# Written in [Amber](https://amber-lang.com/)
# version: 0.5.1-alpha
# We cannot import `bash_version` from `env.ab` because it imports `text.ab` making a circular dependency.
# This is a workaround to avoid that issue and the import system should be improved in the future.
file_exists__37_v0() {
    local path=$1
    [ -f "${path}" ]
    __status=$?
    ret_file_exists37_v0="$(( ${__status} == 0 ))"
    return 0
}

file_chmod__45_v0() {
    local path=$1
    local mode=$2
    file_exists__37_v0 "${path}"
    ret_file_exists37_v0__153_8="${ret_file_exists37_v0}"
    if [ "${ret_file_exists37_v0__153_8}" != 0 ]; then
        chmod "${mode}" "${path}"
        __status=$?
        if [ "${__status}" != 0 ]; then
            ret_file_chmod45_v0=''
            return "${__status}"
        fi
        ret_file_chmod45_v0=''
        return 0
    fi
    echo "The file ${path} doesn't exist"'!'""
    ret_file_chmod45_v0=''
    return 1
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

user_name_3="LZhenHong"
project_name_4="Americano"
app_name_5="${project_name_4}.app"
archive_name_6="${project_name_4}.xcarchive"
release_folder_7="./Releases"
version_8="1.0.0"
env_var_get__98_v0 "PATH"
__status=$?
path_9="${ret_env_var_get98_v0}"
prepare__122_v0() {
    local shell_file=$1
    set -e
    __status=$?
    if [ "${__status}" != 0 ]; then
        ret_prepare122_v0=''
        return "${__status}"
    fi
    set -o pipefail
    __status=$?
    if [ "${__status}" != 0 ]; then
        ret_prepare122_v0=''
        return "${__status}"
    fi
    command_2="$(dirname shell_file)"
    __status=$?
    root_dir_11="${command_2}"
    cd "${root_dir_11}/.." || exit
    export PATH=${path_9}:/opt/homebrew/bin/
    __status=$?
    export https_proxy=http://127.0.0.1:6152;export http_proxy=http://127.0.0.1:6152;export all_proxy=socks5://127.0.0.1:6153
    __status=$?
    pushd ${archive_name_6}/Products/Applications/ >/dev/null 2>&1
    __status=$?
    if [ "${__status}" != 0 ]; then
        ret_prepare122_v0=''
        return "${__status}"
    fi
    command_3="$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" ${app_name_5}/Contents/Info.plist)"
    __status=$?
    if [ "${__status}" != 0 ]; then
        ret_prepare122_v0=''
        return "${__status}"
    fi
    version_8="${command_3}"
    popd >/dev/null 2>&1
    __status=$?
    if [ "${__status}" != 0 ]; then
        ret_prepare122_v0=''
        return "${__status}"
    fi
}

gen_cast__123_v0() {
    gen_path_12="./Build/SourcePackages/artifacts/sparkle/Sparkle/bin/generate_appcast"
    file_exists__37_v0 "${gen_path_12}"
    ret_file_exists37_v0__32_8="${ret_file_exists37_v0}"
    if [ "${ret_file_exists37_v0__32_8}" != 0 ]; then
        file_chmod__45_v0 "${gen_path_12}" "+x"
        __status=$?
        if [ "${__status}" != 0 ]; then
            echo "[*] generate_appcast chmod failed."
        fi
        appcast_file_13="./appcast.xml"
        download_prefix_14="https://github.com/${user_name_3}/${project_name_4}/releases/download/v${version_8}/"
        ${gen_path_12} -o ${appcast_file_13} --download-url-prefix ${download_prefix_14} ${release_folder_7}
        __status=$?
        if [ "${__status}" != 0 ]; then
            ret_gen_cast123_v0=''
            return "${__status}"
        fi
    else
        echo "[*] generate_appcast not found."
    fi
}

git_commit__124_v0() {
    git add appcast.xml
    __status=$?
    git commit -m "[UPDATE] Version ${version_8}."
    __status=$?
    git tag -a v${version_8} -m "Version ${version_8}."
    __status=$?
    if [ "$(( ${__status} == 0 ))" != 0 ]; then
        echo "[*] git commit success."
    else
        echo_error__116_v0 "git commit failed." "${__status}"
    fi
}

declare -r input_args_10=("$0" "$@")
prepare__122_v0 "${input_args_10[0]}"
__status=$?
if [ "${__status}" != 0 ]; then
    echo_error__116_v0 "Failed to prepare." "${__status}"
fi
gen_cast__123_v0 
__status=$?
if [ "${__status}" != 0 ]; then
    echo_error__116_v0 "Failed to generate appcast." "${__status}"
fi
git_commit__124_v0 
