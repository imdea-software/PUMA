#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
adb push ${DIR}/haos /data/local/tmp
adb shell "chmod 0755 /data/local/tmp/haos"
adb shell "ls -l /data/local/tmp/haos"

adb shell "mkdir -p /data/local/tmp/local/tmp"
