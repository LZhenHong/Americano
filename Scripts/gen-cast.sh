#!/usr/bin/env bash
# Written in [Amber](https://amber-lang.com/)
# version: 0.4.0-alpha
# date: 2025-03-10 16:24:33

file_exists__33_v0() {
    local path=$1
     [ -f "${path}" ] ;
    __AS=$?;
if [ $__AS != 0 ]; then
        __AF_file_exists33_v0=0;
        return 0
fi
    __AF_file_exists33_v0=1;
    return 0
}
file_chmod__39_v0() {
    local path=$1
    local mode=$2
    file_exists__33_v0 "${path}";
    __AF_file_exists33_v0__61_8="$__AF_file_exists33_v0";
    if [ "$__AF_file_exists33_v0__61_8" != 0 ]; then
         chmod "${mode}" "${path}" ;
        __AS=$?
        __AF_file_chmod39_v0=1;
        return 0
fi
    echo "The file ${path} doesn't exist"'!'""
    __AF_file_chmod39_v0=0;
    return 0
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
__0_user_name="LZhenHong"
__1_project_name="Americano"
__2_app_name="${__1_project_name}.app"
__3_archive_name="${__1_project_name}.xcarchive"
__4_release_folder="./Releases"
__5_version="1.0.0"
env_var_get__91_v0 "PATH";
__AS=$?;
__AF_env_var_get91_v0__10_18="${__AF_env_var_get91_v0}";
__6_path="${__AF_env_var_get91_v0__10_18}"
prepare__114_v0() {
    local shell_file=$1
    set -e;
    __AS=$?;
if [ $__AS != 0 ]; then
__AF_prepare114_v0=''
return $__AS
fi
    set -o pipefail;
    __AS=$?;
if [ $__AS != 0 ]; then
__AF_prepare114_v0=''
return $__AS
fi
    __AMBER_VAL_2=$(dirname shell_file);
    __AS=$?;
    local root_dir="${__AMBER_VAL_2}"
    cd "${root_dir}/.." || exit
            export PATH=${__6_path}:/opt/homebrew/bin/;
        __AS=$?
        export https_proxy=http://127.0.0.1:6152;export http_proxy=http://127.0.0.1:6152;export all_proxy=socks5://127.0.0.1:6153;
        __AS=$?
    pushd ${__3_archive_name}/Products/Applications/ > /dev/null 2>&1;
    __AS=$?;
if [ $__AS != 0 ]; then
__AF_prepare114_v0=''
return $__AS
fi
    __AMBER_VAL_3=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" ${__2_app_name}/Contents/Info.plist);
    __AS=$?;
if [ $__AS != 0 ]; then
__AF_prepare114_v0=''
return $__AS
fi;
    __5_version="${__AMBER_VAL_3}"
    popd > /dev/null 2>&1;
    __AS=$?;
if [ $__AS != 0 ]; then
__AF_prepare114_v0=''
return $__AS
fi
}
gen_cast__115_v0() {
    local gen_path="./Build/SourcePackages/artifacts/sparkle/Sparkle/bin/generate_appcast"
    file_exists__33_v0 "${gen_path}";
    __AF_file_exists33_v0__32_8="$__AF_file_exists33_v0";
    if [ "$__AF_file_exists33_v0__32_8" != 0 ]; then
        file_chmod__39_v0 "${gen_path}" "+x";
        __AF_file_chmod39_v0__33_12="$__AF_file_chmod39_v0";
        if [ "$__AF_file_chmod39_v0__33_12" != 0 ]; then
            local appcast_file="./appcast.xml"
            local download_prefix="https://github.com/${__0_user_name}/${__1_project_name}/releases/download/v${__5_version}/"
            ${gen_path} -o ${appcast_file} --download-url-prefix ${download_prefix} ${__4_release_folder};
            __AS=$?;
if [ $__AS != 0 ]; then
__AF_gen_cast115_v0=''
return $__AS
fi
else
            echo "[*] generate_appcast chmod failed."
fi
else
        echo "[*] generate_appcast not found."
fi
}
git_commit__116_v0() {
            git add appcast.xml;
        __AS=$?
        git commit -m "[UPDATE] Version ${__5_version}.";
        __AS=$?
        git tag -a v${__5_version} -m "Version ${__5_version}.";
        __AS=$?
    if [ $(echo $__AS '==' 0 | bc -l | sed '/\./ s/\.\{0,1\}0\{1,\}$//') != 0 ]; then
        echo "[*] git commit success."
else
        echo_error__109_v0 "git commit failed." $__AS;
        __AF_echo_error109_v0__55_9="$__AF_echo_error109_v0";
        echo "$__AF_echo_error109_v0__55_9" > /dev/null 2>&1
fi
}
declare -r input_args=("$0" "$@")
    prepare__114_v0 "${input_args[0]}";
    __AS=$?;
if [ $__AS != 0 ]; then
        echo_error__109_v0 "Failed to prepare." $__AS;
        __AF_echo_error109_v0__61_9="$__AF_echo_error109_v0";
        echo "$__AF_echo_error109_v0__61_9" > /dev/null 2>&1
fi;
    __AF_prepare114_v0__60_5="$__AF_prepare114_v0";
    echo "$__AF_prepare114_v0__60_5" > /dev/null 2>&1
    gen_cast__115_v0 ;
    __AS=$?;
if [ $__AS != 0 ]; then
        echo_error__109_v0 "Failed to generate appcast." $__AS;
        __AF_echo_error109_v0__65_9="$__AF_echo_error109_v0";
        echo "$__AF_echo_error109_v0__65_9" > /dev/null 2>&1
fi;
    __AF_gen_cast115_v0__64_5="$__AF_gen_cast115_v0";
    echo "$__AF_gen_cast115_v0__64_5" > /dev/null 2>&1
    git_commit__116_v0 ;
    __AF_git_commit116_v0__68_5="$__AF_git_commit116_v0";
    echo "$__AF_git_commit116_v0__68_5" > /dev/null 2>&1
