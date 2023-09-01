#!/system/bin/sh
. /data/adb/clash/clash_settings.ini
export PATH="/data/adb/magisk:/data/adb/ksu/bin:$PATH:/data/data/com.termux/files/usr/bin"
######################
##  ADVANCE SETTINGS
######################
# dont change anything here if u dont understand!!!

ipv6="false"
pref_id="5000"
mark_id="2022"
table_id="2022"
mode="blacklist"

AUTO_UPDATE_CONFIG="true"
AUTO_UPDATE_GEOX="false"
UPDATE_INTERVAL="0 2 * * *"

DATE_DAY=`date "+%a %b %d [%R:%M] %Z %Y"`

ADB_DIR="/data/adb"
CLASH_DATA_DIR="${ADB_DIR}/clash"
BINARY_DIR="${ADB_DIR}/modules/Clash4Magisk/system/bin"
MODUL_DIR="${ADB_DIR}/modules/Clash4Magisk"
SYSTEM_PACKAGES_FILE="/data/system/packages.list"

CLASH_CONFIG_DIR="${CLASH_DATA_DIR}/config"
TEMP_CONFIG="${CLASH_DATA_DIR}/run/temp.yaml"
TEMPLATE_FILE="${CLASH_CONFIG_DIR}/_template"
PROXIES_FILE="${CLASH_CONFIG_DIR}/_proxies"

CLASH_RUN_PATH="${CLASH_DATA_DIR}/run"
CFM_LOGS_FILE="${CLASH_RUN_PATH}/run.log"
APPUID_FILE="${CLASH_RUN_PATH}/appuid.list"
CLASH_PID_FILE="${CLASH_RUN_PATH}/clash.pid"

SCRIPTS_DIR="${CLASH_DATA_DIR}/scripts"
CLASH_BIN_PATH="${CLASH_DATA_DIR}/core/${CORE_NAME}"

CLASH_CONFIG_FILE="${CLASH_CONFIG_DIR}/${CONFIG_NAME}"
CLASH_GEOIP_FILE="${CLASH_CONFIG_DIR}/Country.mmdb"
CLASH_GEOIP_URL="https://github.com/Loyalsoldier/geoip/raw/release/Country.mmdb"
CLASH_GEOSITE_FILE="${CLASH_CONFIG_DIR}/GeoSite.dat"
CLASH_GEOSITE_URL="https://github.com/CHIZI-0618/v2ray-rules-dat/raw/release/geosite.dat"
FILTER_PACKAGES_FILE="${CLASH_DATA_DIR}/packages.list"

AUTO_SUBSCRIPTION="false"
SUBSCRIPTION_URL=""
FILTER_LOCAL="false"

CLASH_PERMISSIONS="6755"
CLASH_USER_GROUP="root:net_admin"

IPTABLES_WAIT="iptables -w 100"
CLASH_GROUP=`echo ${CLASH_USER_GROUP} | awk -F ':' '{print $2}'`
CLASH_DNS_PORT=`grep "listen" ${TEMPLATE_FILE} | awk -F ':' '{print $3}'`
CLASH_TPROXY_PORT=`grep "tproxy-port" ${TEMPLATE_FILE} | awk -F ':' '{print $2}'`
