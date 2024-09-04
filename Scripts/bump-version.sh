#!/usr/bin/env bash
# Written in [Amber](https://amber-lang.com/)
# version: 0.3.4-alpha
# date: 2024-08-31 17:07:33
function parse__19_v0 {
    local text=$1
    [ -n "${text}" ] && [ "${text}" -eq "${text}" ] 2>/dev/null;
    __AS=$?;
if [ $__AS != 0 ]; then
__AF_parse19_v0=''
return $__AS
fi
    __AF_parse19_v0="${text}";
    return 0
}
    __AMBER_VAL_0=$(printf "$SRCROOT");
    __AS=$?;
    SRCROOT="${__AMBER_VAL_0}"
    __AMBER_VAL_1=$(printf "$PRODUCT_NAME");
    __AS=$?;
    PRODUCT_NAME="${__AMBER_VAL_1}"
    cd "${SRCROOT}/${PRODUCT_NAME}/Resources";
    __AS=$?
__0_file_name="Config.xcconfig"
function increase_build_number__45_v0 {
    __AMBER_VAL_2=$(awk -F "=" '/BUILD_NUMBER/ {print $2}' ${__0_file_name} |         tr -d ' ');
    __AS=$?;
if [ $__AS != 0 ]; then
        echo "Failed to get previous build number"
        __AF_increase_build_number45_v0='';
        return $__AS
fi;
    local previous_build="${__AMBER_VAL_2}"
    __AMBER_VAL_3=$(date "+%Y%m%d");
    __AS=$?;
    local current_date="${__AMBER_VAL_3}"
    __AMBER_VAL_4=$(printf "${previous_build:0:8}");
    __AS=$?;
    local previous_date="${__AMBER_VAL_4}"
    __AMBER_VAL_5=$(printf "${previous_build:8}");
    __AS=$?;
    parse__19_v0 "${__AMBER_VAL_5}";
    __AS=$?;
if [ $__AS != 0 ]; then
        echo "Failed to parse previous build number"
        __AF_increase_build_number45_v0='';
        return $__AS
fi;
    __AF_parse19_v0__19_19=$__AF_parse19_v0;
    local counter=$__AF_parse19_v0__19_19
    local new_counter=$(if [ $([ "_${current_date}" != "_${previous_date}" ]; echo $?) != 0 ]; then echo $(echo ${counter} '+' 1 | bc -l | sed '/\./ s/\.\{0,1\}0\{1,\}$//'); else echo 1; fi)
    local new_build="${current_date}"${new_counter}
    sed -i -e "/BUILD_NUMBER =/ s/= .*/= ${new_build}/" ${__0_file_name};
    __AS=$?;
if [ $__AS != 0 ]; then
        echo "Failed to update build number"
        __AF_increase_build_number45_v0='';
        return $__AS
fi
    local tmp_file="${__0_file_name}-e"
    rm -f ${tmp_file};
    __AS=$?;
if [ $__AS != 0 ]; then
__AF_increase_build_number45_v0=''
return $__AS
fi
}

    increase_build_number__45_v0 ;
    __AS=$?;
if [ $__AS != 0 ]; then

exit $__AS
fi;
    __AF_increase_build_number45_v0__37_5=$__AF_increase_build_number45_v0;
    echo $__AF_increase_build_number45_v0__37_5 > /dev/null 2>&1