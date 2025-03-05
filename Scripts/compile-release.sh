#!/usr/bin/env bash
# Written in [Amber](https://amber-lang.com/)
# version: 0.4.0-alpha
# date: 2025-03-05 22:14:41


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
__1_app_name="${__0_project_name}.app"
__2_archive_name="${__0_project_name}.xcarchive"
env_var_get__91_v0 "PATH";
__AS=$?;
__AF_env_var_get91_v0__6_18="${__AF_env_var_get91_v0}";
__3_path="${__AF_env_var_get91_v0__6_18}"
prepare__112_v0() {
    local shell_file=$1
    set -e;
    __AS=$?;
if [ $__AS != 0 ]; then
__AF_prepare112_v0=''
return $__AS
fi
    set -o pipefail;
    __AS=$?;
if [ $__AS != 0 ]; then
__AF_prepare112_v0=''
return $__AS
fi
    __AMBER_VAL_2=$(dirname shell_file);
    __AS=$?;
    local root_dir="${__AMBER_VAL_2}"
    cd "${root_dir}/.." || exit
    rm -rf Build *.xcarchive *.zip || true;
    __AS=$?
            rm -rf Build *.xcarchive || true;
        __AS=$?
        export PATH=${__3_path}:/opt/homebrew/bin/;
        __AS=$?
}
build__113_v0() {
    xcodebuild         -scheme ${__0_project_name}         -derivedDataPath Build         -configuration Release         -destination 'platform=macOS'         -archivePath ${__2_archive_name}         clean archive         CODE_SIGN_IDENTITY="" CODE_SIGN_ENTITLEMENTS="" CODE_SIGNING_ALLOWED=NO         | xcbeautify;
    __AS=$?;
if [ $__AS != 0 ]; then
__AF_build113_v0=''
return $__AS
fi
}
extract__114_v0() {
    local target_dir=$1
    pushd ${__2_archive_name}/Products/Applications/ > /dev/null 2>&1;
    __AS=$?;
if [ $__AS != 0 ]; then
__AF_extract114_v0=''
return $__AS
fi
    __AMBER_VAL_3=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" ${__1_app_name}/Contents/Info.plist);
    __AS=$?;
if [ $__AS != 0 ]; then
__AF_extract114_v0=''
return $__AS
fi;
    local version="${__AMBER_VAL_3}"
    local zip_name="${target_dir}/${__1_app_name}-${version}.zip"
    zip -r ${zip_name} ${__1_app_name};
    __AS=$?;
if [ $__AS != 0 ]; then
__AF_extract114_v0=''
return $__AS
fi
    popd > /dev/null 2>&1;
    __AS=$?;
if [ $__AS != 0 ]; then
__AF_extract114_v0=''
return $__AS
fi
}
declare -r args=("$0" "$@")
    prepare__112_v0 "${args[0]}";
    __AS=$?;
if [ $__AS != 0 ]; then
        echo_error__109_v0 "Failed to prepare." $__AS;
        __AF_echo_error109_v0__50_9="$__AF_echo_error109_v0";
        echo "$__AF_echo_error109_v0__50_9" > /dev/null 2>&1
fi;
    __AF_prepare112_v0__49_5="$__AF_prepare112_v0";
    echo "$__AF_prepare112_v0__49_5" > /dev/null 2>&1
    build__113_v0 ;
    __AS=$?;
if [ $__AS != 0 ]; then
        echo_error__109_v0 "Failed to build." $__AS;
        __AF_echo_error109_v0__54_9="$__AF_echo_error109_v0";
        echo "$__AF_echo_error109_v0__54_9" > /dev/null 2>&1
fi;
    __AF_build113_v0__53_5="$__AF_build113_v0";
    echo "$__AF_build113_v0__53_5" > /dev/null 2>&1
    __AMBER_VAL_4=$(pwd);
    __AS=$?;
    target_dir="${__AMBER_VAL_4}"
    __AMBER_LEN="${args[1]}";
    if [ $(echo $(echo "${#args[@]}" '>' 1 | bc -l | sed '/\./ s/\.\{0,1\}0\{1,\}$//') '&&' $(echo "${#__AMBER_LEN}" '>' 0 | bc -l | sed '/\./ s/\.\{0,1\}0\{1,\}$//') | bc -l | sed '/\./ s/\.\{0,1\}0\{1,\}$//') != 0 ]; then
        target_dir="${args[1]}"
fi
    extract__114_v0 "${target_dir}";
    __AS=$?;
if [ $__AS != 0 ]; then
        echo_error__109_v0 "Failed to extract." $__AS;
        __AF_echo_error109_v0__63_9="$__AF_echo_error109_v0";
        echo "$__AF_echo_error109_v0__63_9" > /dev/null 2>&1
fi;
    __AF_extract114_v0__62_5="$__AF_extract114_v0";
    echo "$__AF_extract114_v0__62_5" > /dev/null 2>&1
    echo "[*] done build."
