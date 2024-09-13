#!/usr/bin/env bash
# Written in [Amber](https://amber-lang.com/)
# version: 0.3.5-alpha
# date: 2024-09-13 14:32:50

parse__30_v0() {
    local text=$1
    [ -n "${text}" ] && [ "${text}" -eq "${text}" ] 2>/dev/null;
    __AS=$?;
if [ $__AS != 0 ]; then
__AF_parse30_v0=''
return $__AS
fi
    __AF_parse30_v0="${text}";
    return 0
}
len__32_v0() {
    local value=$1
            if [ 1 != 0 ]; then
            __AMBER_VAL_0=$(echo "${#value}");
            __AS=$?;
            __AF_len32_v0="${__AMBER_VAL_0}";
            return 0
else
            __AMBER_VAL_1=$(echo "${#value[@]}");
            __AS=$?;
            __AF_len32_v0="${__AMBER_VAL_1}";
            return 0
fi
}
slice__37_v0() {
    local text=$1
    local index=$2
    local length=$3
    if [ $(echo ${length} '==' 0 | bc -l | sed '/\./ s/\.\{0,1\}0\{1,\}$//') != 0 ]; then
        len__32_v0 "${text}";
        __AF_len32_v0__129_30="$__AF_len32_v0";
        length=$(echo "$__AF_len32_v0__129_30" '-' ${index} | bc -l | sed '/\./ s/\.\{0,1\}0\{1,\}$//')
fi
    if [ $(echo ${length} '<=' 0 | bc -l | sed '/\./ s/\.\{0,1\}0\{1,\}$//') != 0 ]; then
        __AF_slice37_v0="";
        return 0
fi
    __AMBER_VAL_2=$(printf "%.${length}s" "${text:${index}}");
    __AS=$?;
    __AF_slice37_v0="${__AMBER_VAL_2}";
    return 0
}
shell_var_get__74_v0() {
    local name=$1
    __AMBER_VAL_3=$(echo ${!name});
    __AS=$?;
if [ $__AS != 0 ]; then
__AF_shell_var_get74_v0=''
return $__AS
fi;
    __AF_shell_var_get74_v0="${__AMBER_VAL_3}";
    return 0
}
    shell_var_get__74_v0 "SRCROOT";
    __AS=$?;
    __AF_shell_var_get74_v0__5_20="${__AF_shell_var_get74_v0}";
    src_root="${__AF_shell_var_get74_v0__5_20}"
    shell_var_get__74_v0 "PRODUCT_NAME";
    __AS=$?;
    __AF_shell_var_get74_v0__6_24="${__AF_shell_var_get74_v0}";
    product_name="${__AF_shell_var_get74_v0__6_24}"
    cd "${src_root}/${product_name}/Resources" || exit
__0_file_name="Config.xcconfig"
increase_build_number__97_v0() {
    __AMBER_VAL_4=$(awk -F "=" '/BUILD_NUMBER/ {print $2}' ${__0_file_name} |         tr -d ' ');
    __AS=$?;
if [ $__AS != 0 ]; then
        echo "Failed to get previous build number"
        __AF_increase_build_number97_v0='';
        return $__AS
fi;
    local previous_build="${__AMBER_VAL_4}"
    __AMBER_VAL_5=$(date "+%Y%m%d");
    __AS=$?;
    local current_date="${__AMBER_VAL_5}"
    slice__37_v0 "${previous_build}" 0 8;
    __AF_slice37_v0__19_25="${__AF_slice37_v0}";
    local previous_date="${__AF_slice37_v0__19_25}"
    slice__37_v0 "${previous_build}" 8 0;
    __AF_slice37_v0__20_25="${__AF_slice37_v0}";
    parse__30_v0 "${__AF_slice37_v0__20_25}";
    __AS=$?;
if [ $__AS != 0 ]; then
        echo "Failed to parse previous build number"
        __AF_increase_build_number97_v0='';
        return $__AS
fi;
    __AF_parse30_v0__20_19="$__AF_parse30_v0";
    local counter="$__AF_parse30_v0__20_19"
    local new_counter=$(if [ $([ "_${current_date}" != "_${previous_date}" ]; echo $?) != 0 ]; then echo $(echo ${counter} '+' 1 | bc -l | sed '/\./ s/\.\{0,1\}0\{1,\}$//'); else echo 1; fi)
    local new_build="${current_date}"${new_counter}
    sed -i -e "/BUILD_NUMBER =/ s/= .*/= ${new_build}/" ${__0_file_name};
    __AS=$?;
if [ $__AS != 0 ]; then
        echo "Failed to update build number"
        __AF_increase_build_number97_v0='';
        return $__AS
fi
    local tmp_file="${__0_file_name}-e"
    rm -f ${tmp_file};
    __AS=$?;
if [ $__AS != 0 ]; then
__AF_increase_build_number97_v0=''
return $__AS
fi
    echo "Bumped Build Number: ${new_build}"
}
increase_version__98_v0() {
    __AMBER_VAL_6=$(awk -F "=" '/VERSION/ {print $2}' ${__0_file_name} |         tr -d ' ');
    __AS=$?;
if [ $__AS != 0 ]; then
        echo "Failed to get previous version"
        __AF_increase_version98_v0='';
        return $__AS
fi;
    local version="${__AMBER_VAL_6}"
    echo "Previous Version: ${version}"
    __AMBER_VAL_7=$(echo ${version} | cut -d. -f1);
    __AS=$?;
if [ $__AS != 0 ]; then
__AF_increase_version98_v0=''
return $__AS
fi;
    parse__30_v0 "${__AMBER_VAL_7}";
    __AS=$?;
if [ $__AS != 0 ]; then
__AF_increase_version98_v0=''
return $__AS
fi;
    __AF_parse30_v0__48_17="$__AF_parse30_v0";
    local major="$__AF_parse30_v0__48_17"
    __AMBER_VAL_8=$(echo ${version} | cut -d. -f2);
    __AS=$?;
if [ $__AS != 0 ]; then
__AF_increase_version98_v0=''
return $__AS
fi;
    parse__30_v0 "${__AMBER_VAL_8}";
    __AS=$?;
if [ $__AS != 0 ]; then
__AF_increase_version98_v0=''
return $__AS
fi;
    __AF_parse30_v0__49_17="$__AF_parse30_v0";
    local minor="$__AF_parse30_v0__49_17"
    __AMBER_VAL_9=$(echo ${version} | cut -d. -f3);
    __AS=$?;
if [ $__AS != 0 ]; then
__AF_increase_version98_v0=''
return $__AS
fi;
    parse__30_v0 "${__AMBER_VAL_9}";
    __AS=$?;
if [ $__AS != 0 ]; then
__AF_increase_version98_v0=''
return $__AS
fi;
    __AF_parse30_v0__50_17="$__AF_parse30_v0";
    local patch="$__AF_parse30_v0__50_17"
    shell_var_get__74_v0 "CONFIGURATION";
    __AS=$?;
if [ $__AS != 0 ]; then
__AF_increase_version98_v0=''
return $__AS
fi;
    __AF_shell_var_get74_v0__52_25="${__AF_shell_var_get74_v0}";
    local configuration="${__AF_shell_var_get74_v0__52_25}"
    if [ $([ "_${configuration}" != "_Release" ]; echo $?) != 0 ]; then
        patch=$(echo ${patch} '+' 1 | bc -l | sed '/\./ s/\.\{0,1\}0\{1,\}$//')
fi
    local new_version="${major}.${minor}.${patch}"
    sed -i -e "/VERSION =/ s/= .*/= ${new_version}/" ${__0_file_name};
    __AS=$?;
if [ $__AS != 0 ]; then
        echo "Failed to update version"
        __AF_increase_version98_v0='';
        return $__AS
fi
    local tmp_file="${__0_file_name}-e"
    rm -f ${tmp_file};
    __AS=$?;
if [ $__AS != 0 ]; then
__AF_increase_version98_v0=''
return $__AS
fi
    echo "Bumped Version: ${new_version}"
}

    increase_build_number__97_v0 ;
    __AS=$?;
if [ $__AS != 0 ]; then

exit $__AS
fi;
    __AF_increase_build_number97_v0__69_5="$__AF_increase_build_number97_v0";
    echo "$__AF_increase_build_number97_v0__69_5" > /dev/null 2>&1
    shell_var_get__74_v0 "BUMP_VERSION";
    __AS=$?;
if [ $__AS != 0 ]; then

exit $__AS
fi;
    __AF_shell_var_get74_v0__71_22="${__AF_shell_var_get74_v0}";
    parse__30_v0 "${__AF_shell_var_get74_v0__71_22}";
    __AS=$?;
if [ $__AS != 0 ]; then

exit $__AS
fi;
    __AF_parse30_v0__71_16="$__AF_parse30_v0";
    bump=$(echo "$__AF_parse30_v0__71_16" '==' 1 | bc -l | sed '/\./ s/\.\{0,1\}0\{1,\}$//')
    if [ ${bump} != 0 ]; then
        increase_version__98_v0 ;
        __AS=$?;
if [ $__AS != 0 ]; then

exit $__AS
fi;
        __AF_increase_version98_v0__73_9="$__AF_increase_version98_v0";
        echo "$__AF_increase_version98_v0__73_9" > /dev/null 2>&1
else
        echo "Skipping version bump"
fi
