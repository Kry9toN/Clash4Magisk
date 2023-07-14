#!/system/bin/sh

export PATH="/data/adb/magisk:/data/adb/ksu/bin:$PATH:/data/data/com.termux/files/usr/bin"

MOD_DIR="/data/adb/modules/Clash4Magisk"

CLASH_DIR="/data/adb/clash"
SCRIPTS_DIR="${CLASH_DIR}/scripts"
CLASH_RUN_PATH="${CLASH_DIR}/run"
CLASH_PID_FILE="${CLASH_RUN_PATH}/clash.pid"

start_service() {
  ${SCRIPTS_DIR}/clash.service -s && ${SCRIPTS_DIR}/clash.tproxy -s
}

nohup busybox crond -c ${CLASH_RUN_PATH} > /dev/null 2>&1 &

[[ -f ${CLASH_PID_FILE} ]] && rm -f ${CLASH_PID_FILE}

if [[ ! -f ${CLASH_DIR}/manual ]]; then
    if [[ ! -f ${MOD_DIR}/disable ]]; then
       start_service
    fi
    inotifyd "${SCRIPTS_DIR}/clash.inotify" "${MOD_DIR}" &> /dev/null &
fi
