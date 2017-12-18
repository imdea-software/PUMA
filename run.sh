#!/usr/bin/env bash

if [ $# -ne 3 ]; then
  echo "Usage: $0 <app_apk_path> <time_to_run_puma_in_min> <SDK>"
  echo "Example: $0 \"/home/vagrant/subjects/a2dp.Vol_93_src\" \"10\" \"19\""
  exit
fi

app_apk_path=$1
if [[  ! -e ${app_apk_path} ]]; then
  echo "This app folder: ${app_apk_path} - Doesn't exist or match with more than 1"
  echo "Run again with a correct folder name."
  exit 1
fi

time=$2
if [[  -z ${time} ]]; then
  echo "This var: time - Not setted"
  echo "Run again passing the correct time number"
  exit 1
fi

SDK=${3:-19}
if [[ -z ${SDK} ]]; then
  echo "This var: SDK - Not setted"
  echo "Run again passing the correct time number"
  exit 1
fi
SDK_name="android-${SDK}"


DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd ${DIR}

APPINFO=${DIR}/app.info
UID_FN=/data/local/tmp/app.uid
UID_FN_BackUp=${DIR}/app.uid_BackUpFromEMU



# get info from apk
package=$(aapt d xmltree ${app_apk_path} AndroidManifest.xml | grep package | awk 'BEGIN {FS="\""}{print $2}')
echo ${package} > ${APPINFO}
appLabel=$(aapt d badging ${app_apk_path} | grep application-label: | awk -F\' '{print $2}')
echo ${appLabel} >> ${APPINFO}
echo ${time} >> ${APPINFO}


CMD="adb push ${APPINFO} /data/local/tmp"
echo "        * ${CMD}"
eval ${CMD}
[[ $? -ne 0 ]] && echo "ERROR" && exit 1


APP=$(head -1 ${APPINFO})


echo "0. Start app from fresh"

CMD="adb shell \"am force-stop ${APP}\""
echo "        * ${CMD}"
eval ${CMD}
[[ $? -ne 0 ]] && echo "ERROR" && exit 1


echo "1. Find and save UID, if needed"

curr_uid=`adb shell dumpsys package ${APP} | grep userId | awk -F"=| " '{print $6}'`
old_uid=`adb shell "cat ${UID_FN}" | tr -d '\r\n'`

if [ "${curr_uid}" != "${old_uid}" ]; then
  echo "Updating UID"
  adb shell "echo ${curr_uid} > ${UID_FN}"
  adb shell "cat ${UID_FN}"  >  ${UID_FN_BackUp}
else
  echo "UID OK"
fi


echo "2. Start command"

CMD="android update project -t ${SDK_name} -p . --subprojects"
echo "        * ${CMD}"
eval ${CMD}
[[ $? -ne 0 ]] && echo "ERROR" && exit 1

CMD="ant build"
echo "        * ${CMD}"
eval ${CMD}
[[ $? -ne 0 ]] && echo "ERROR" && exit 1

CMD="adb push ${DIR}/bin/TestApp.jar /data/local/tmp/"
echo "        * ${CMD}"
eval ${CMD}
[[ $? -ne 0 ]] && echo "ERROR" && exit 1

CMD="adb shell /data/local/tmp/haos runtest TestApp.jar -c nsl.stg.tests.LaunchApp"
echo "        * ${CMD}"
eval ${CMD}
[[ $? -ne 0 ]] && echo "ERROR" && exit 1

exit 0
