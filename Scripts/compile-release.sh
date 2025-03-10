#!/usr/bin/env bash
# Written in [Amber](https://amber-lang.com/)
# version: 0.4.0-alpha
# date: 2025-03-10 15:27:22

dir_exists__32_v0() {
    local path=$1
     [ -d "${path}" ] ;
    __AS=$?;
if [ $__AS != 0 ]; then
        __AF_dir_exists32_v0=0;
        return 0
fi
    __AF_dir_exists32_v0=1;
    return 0
}
dir_create__38_v0() {
    local path=$1
    dir_exists__32_v0 "${path}";
    __AF_dir_exists32_v0__52_12="$__AF_dir_exists32_v0";
    if [ $(echo  '!' "$__AF_dir_exists32_v0__52_12" | bc -l | sed '/\./ s/\.\{0,1\}0\{1,\}$//') != 0 ]; then
         mkdir -p "${path}" ;
        __AS=$?
fi
}
env_var_get__91_v0() {
    local name=$1
    __AMBER_VAL_0=$( echo ${!name} );
    __AS=$?;
if [ $__AS != 0 ]; then
__AF_env_var_get91_v0=''
return $__AS
fi;
    __AF_env_var_get91_v0="${__AMBER_VAL_0}";
    return 0
}
printf__99_v0() {
    local format=$1
    local args=("${!2}")
     args=("${format}" "${args[@]}") ;
    __AS=$?
     printf "${args[@]}" ;
    __AS=$?
}
echo_error__109_v0() {
    local message=$1
    local exit_code=$2
    __AMBER_ARRAY_1=("${message}");
    printf__99_v0 "\x1b[1;3;97;41m%s\x1b[0m
" __AMBER_ARRAY_1[@];
    __AF_printf99_v0__162_5="$__AF_printf99_v0";
    echo "$__AF_printf99_v0__162_5" > /dev/null 2>&1
    if [ $(echo ${exit_code} '>' 0 | bc -l | sed '/\./ s/\.\{0,1\}0\{1,\}$//') != 0 ]; then
        exit ${exit_code}
fi
}
__0_project_name="Americano"
__1_release_folder="Releases"
__2_app_name="${__0_project_name}.app"
__3_archive_name="${__0_project_name}.xcarchive"
env_var_get__91_v0 "PATH";
__AS=$?;
__AF_env_var_get91_v0__8_18="${__AF_env_var_get91_v0}";
__4_path="${__AF_env_var_get91_v0__8_18}"
prepare__113_v0() {
    local shell_file=$1
    # $set -e$?
    set -o pipefail;
    __AS=$?;
if [ $__AS != 0 ]; then
__AF_prepare113_v0=''
return $__AS
fi
    __AMBER_VAL_2=$(dirname shell_file);
    __AS=$?;
    local root_dir="${__AMBER_VAL_2}"
    cd "${root_dir}/.." || exit
    dir_create__38_v0 "${__1_release_folder}";
    __AF_dir_create38_v0__18_5="$__AF_dir_create38_v0";
    echo "$__AF_dir_create38_v0__18_5" > /dev/null 2>&1
            rm -rf Build Archive *.xcarchive *.zip || true;
        __AS=$?
        export PATH=${__4_path}:/opt/homebrew/bin/;
        __AS=$?
        export https_proxy=http://127.0.0.1:6152;export http_proxy=http://127.0.0.1:6152;export all_proxy=socks5://127.0.0.1:6153;
        __AS=$?
}
build__114_v0() {
    xcodebuild archive         -scheme ${__0_project_name}         -derivedDataPath Build         -configuration Release         -destination 'platform=macOS'         -archivePath ${__3_archive_name}         clean archive         CODE_SIGN_IDENTITY="" CODE_SIGN_ENTITLEMENTS="" CODE_SIGNING_ALLOWED=NO         | xcbeautify;
    __AS=$?;
if [ $__AS != 0 ]; then
__AF_build114_v0=''
return $__AS
fi
}
extract__115_v0() {
    local target_dir=$1
    pushd ${__3_archive_name}/Products/Applications/ > /dev/null 2>&1;
    __AS=$?;
if [ $__AS != 0 ]; then
__AF_extract115_v0=''
return $__AS
fi
    local zip_name="${target_dir}/${__2_app_name}.zip"
    zip -r ${zip_name} ${__2_app_name};
    __AS=$?;
if [ $__AS != 0 ]; then
__AF_extract115_v0=''
return $__AS
fi
    popd > /dev/null 2>&1;
    __AS=$?;
if [ $__AS != 0 ]; then
__AF_extract115_v0=''
return $__AS
fi
}
declare -r input_args=("$0" "$@")
    echo "[*] start build."
    prepare__113_v0 "${input_args[0]}";
    __AS=$?;
if [ $__AS != 0 ]; then
        echo_error__109_v0 "Failed to prepare." $__AS;
        __AF_echo_error109_v0__53_9="$__AF_echo_error109_v0";
        echo "$__AF_echo_error109_v0__53_9" > /dev/null 2>&1
fi;
    __AF_prepare113_v0__52_5="$__AF_prepare113_v0";
    echo "$__AF_prepare113_v0__52_5" > /dev/null 2>&1
    build__114_v0 ;
    __AS=$?;
if [ $__AS != 0 ]; then
        echo_error__109_v0 "Failed to build." $__AS;
        __AF_echo_error109_v0__57_9="$__AF_echo_error109_v0";
        echo "$__AF_echo_error109_v0__57_9" > /dev/null 2>&1
fi;
    __AF_build114_v0__56_5="$__AF_build114_v0";
    echo "$__AF_build114_v0__56_5" > /dev/null 2>&1
    __AMBER_VAL_3=$(pwd);
    __AS=$?;
    target_dir="${__AMBER_VAL_3}/${__1_release_folder}"
    __AMBER_LEN="${input_args[1]}";
    if [ $(echo $(echo "${#input_args[@]}" '>' 1 | bc -l | sed '/\./ s/\.\{0,1\}0\{1,\}$//') '&&' $(echo "${#__AMBER_LEN}" '>' 0 | bc -l | sed '/\./ s/\.\{0,1\}0\{1,\}$//') | bc -l | sed '/\./ s/\.\{0,1\}0\{1,\}$//') != 0 ]; then
        target_dir="${input_args[1]}"
fi
    extract__115_v0 "${target_dir}";
    __AS=$?;
if [ $__AS != 0 ]; then
        echo_error__109_v0 "Failed to extract." $__AS;
        __AF_echo_error109_v0__66_9="$__AF_echo_error109_v0";
        echo "$__AF_echo_error109_v0__66_9" > /dev/null 2>&1
fi;
    __AF_extract115_v0__65_5="$__AF_extract115_v0";
    echo "$__AF_extract115_v0__65_5" > /dev/null 2>&1
    echo "[*] done build."
