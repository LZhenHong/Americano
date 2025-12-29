#!/usr/bin/env bash
# Written in [Amber](https://amber-lang.com/)
# version: 0.5.1-alpha
# We cannot import `bash_version` from `env.ab` because it imports `text.ab` making a circular dependency.
# This is a workaround to avoid that issue and the import system should be improved in the future.
parse_int__14_v0() {
    local text=$1
    [ -n "${text}" ] && [ "${text}" -eq "${text}" ] 2>/dev/null
    __status=$?
    if [ "${__status}" != 0 ]; then
        ret_parse_int14_v0=''
        return "${__status}"
    fi
    ret_parse_int14_v0="${text}"
    return 0
}

parse_num__15_v0() {
    local text=$1
    re_int_16="^-?[0-9]+\$"
    re_float_17="^-?[0-9]*\\.[0-9]+\$"
    [[ ${text} =~ ${re_int_16} ]] || [[ ${text} =~ ${re_float_17} ]]
    __status=$?
    if [ "${__status}" != 0 ]; then
        ret_parse_num15_v0=''
        return "${__status}"
    fi
    ret_parse_num15_v0="${text}"
    return 0
}

slice__25_v0() {
    local text=$1
    local index=$2
    local length=$3
    if [ "$(( ${length} == 0 ))" != 0 ]; then
        __length_0="${text}"
        length="$(( ${#__length_0} - ${index} ))"
    fi
    if [ "$(( ${length} <= 0 ))" != 0 ]; then
        ret_slice25_v0=""
        return 0
    fi
    command_1="$(printf "%.${length}s" "${text: ${index}}")"
    __status=$?
    ret_slice25_v0="${command_1}"
    return 0
}

env_var_get__98_v0() {
    local name=$1
    command_2="$(echo ${!name})"
    __status=$?
    if [ "${__status}" != 0 ]; then
        ret_env_var_get98_v0=''
        return "${__status}"
    fi
    ret_env_var_get98_v0="${command_2}"
    return 0
}

env_var_get__98_v0 "SRCROOT"
__status=$?
src_root_3="${ret_env_var_get98_v0}"
env_var_get__98_v0 "PRODUCT_NAME"
__status=$?
product_name_4="${ret_env_var_get98_v0}"
cd "${src_root_3}/${product_name_4}/Resources" || exit
file_name_5="Config.xcconfig"
increase_build_number__122_v0() {
    command_3="$(awk -F "=" '/BUILD_NUMBER/ {print $2}' ${file_name_5} |         tr -d ' ')"
    __status=$?
    if [ "${__status}" != 0 ]; then
        echo "Failed to get previous build number"
        ret_increase_build_number122_v0=''
        return "${__status}"
    fi
    previous_build_6="${command_3}"
    command_4="$(date "+%Y%m%d")"
    __status=$?
    current_date_7="${command_4}"
    slice__25_v0 "${previous_build_6}" 0 8
    previous_date_8="${ret_slice25_v0}"
    slice__25_v0 "${previous_build_6}" 8 0
    ret_slice25_v0__20_29="${ret_slice25_v0}"
    parse_int__14_v0 "${ret_slice25_v0__20_29}"
    __status=$?
    if [ "${__status}" != 0 ]; then
        echo "Failed to parse previous build number"
        ret_increase_build_number122_v0=''
        return "${__status}"
    fi
    counter_9="${ret_parse_int14_v0}"
    new_counter_10="$(if [ "$([ "_${current_date_7}" != "_${previous_date_8}" ]; echo $?)" != 0 ]; then echo "$(( ${counter_9} + 1 ))"; else echo 1; fi)"
    command_5="$(printf "%03d" ${new_counter_10})"
    __status=$?
    if [ "${__status}" != 0 ]; then
        echo "Failed to format build number"
        ret_increase_build_number122_v0=''
        return "${__status}"
    fi
    counter_suffix_11="${command_5}"
    new_build_12="${current_date_7}""${counter_suffix_11}"
    sed -i -e "/BUILD_NUMBER =/ s/= .*/= ${new_build_12}/" ${file_name_5}
    __status=$?
    if [ "${__status}" != 0 ]; then
        echo "Failed to update build number"
        ret_increase_build_number122_v0=''
        return "${__status}"
    fi
    tmp_file_13="${file_name_5}-e"
    rm -f ${tmp_file_13}
    __status=$?
    if [ "${__status}" != 0 ]; then
        ret_increase_build_number122_v0=''
        return "${__status}"
    fi
    echo "Bumped Build Number: ${new_build_12}"
}

increase_version__123_v0() {
    command_6="$(awk -F "=" '/VERSION/ {print $2}' ${file_name_5} |         tr -d ' ')"
    __status=$?
    if [ "${__status}" != 0 ]; then
        echo "Failed to get previous version"
        ret_increase_version123_v0=''
        return "${__status}"
    fi
    version_18="${command_6}"
    echo "Previous Version: ${version_18}"
    command_7="$(echo ${version_18} | cut -d. -f1)"
    __status=$?
    if [ "${__status}" != 0 ]; then
        ret_increase_version123_v0=''
        return "${__status}"
    fi
    parse_int__14_v0 "${command_7}"
    __status=$?
    if [ "${__status}" != 0 ]; then
        ret_increase_version123_v0=''
        return "${__status}"
    fi
    major_19="${ret_parse_int14_v0}"
    command_8="$(echo ${version_18} | cut -d. -f2)"
    __status=$?
    if [ "${__status}" != 0 ]; then
        ret_increase_version123_v0=''
        return "${__status}"
    fi
    parse_int__14_v0 "${command_8}"
    __status=$?
    if [ "${__status}" != 0 ]; then
        ret_increase_version123_v0=''
        return "${__status}"
    fi
    minor_20="${ret_parse_int14_v0}"
    command_9="$(echo ${version_18} | cut -d. -f3)"
    __status=$?
    if [ "${__status}" != 0 ]; then
        ret_increase_version123_v0=''
        return "${__status}"
    fi
    parse_int__14_v0 "${command_9}"
    __status=$?
    if [ "${__status}" != 0 ]; then
        ret_increase_version123_v0=''
        return "${__status}"
    fi
    patch_21="${ret_parse_int14_v0}"
    env_var_get__98_v0 "CONFIGURATION"
    __status=$?
    if [ "${__status}" != 0 ]; then
        ret_increase_version123_v0=''
        return "${__status}"
    fi
    configuration_22="${ret_env_var_get98_v0}"
    if [ "$([ "_${configuration_22}" != "_Release" ]; echo $?)" != 0 ]; then
        patch_21="$(( ${patch_21} + 1 ))"
    fi
    new_version_23="${major_19}.${minor_20}.${patch_21}"
    sed -i -e "/VERSION =/ s/= .*/= ${new_version_23}/" ${file_name_5}
    __status=$?
    if [ "${__status}" != 0 ]; then
        echo "Failed to update version"
        ret_increase_version123_v0=''
        return "${__status}"
    fi
    tmp_file_24="${file_name_5}-e"
    rm -f ${tmp_file_24}
    __status=$?
    if [ "${__status}" != 0 ]; then
        ret_increase_version123_v0=''
        return "${__status}"
    fi
    echo "Bumped Version: ${new_version_23}"
}

increase_build_number__122_v0 
__status=$?
if [ "${__status}" != 0 ]; then
    exit "${__status}"
fi
bump_14=0
env_var_get__98_v0 "BUMP_VERSION">/dev/null 2>&1
__status=$?
bump_version_15="${ret_env_var_get98_v0}"
parse_num__15_v0 "${bump_version_15}">/dev/null 2>&1
__status=$?
ret_parse_num15_v0__78_16="${ret_parse_num15_v0}"
bump_14="$(echo ${ret_parse_num15_v0__78_16} '==' 1 | bc -l | sed '/\./ s/\.\{0,1\}0\{1,\}$//')"
if [ "${bump_14}" != 0 ]; then
    increase_version__123_v0 
    __status=$?
    if [ "${__status}" != 0 ]; then
        exit "${__status}"
    fi
else
    echo "Skipping version bump"
fi
