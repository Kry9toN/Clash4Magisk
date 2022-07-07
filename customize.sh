SKIPUNZIP=1

ADB_DIR="/data/adb"
CLASH_DIR="${ADB_DIR}/clash"
MOD_DIR="${ADB_DIR}/modules"
BIN_PATH="/system/bin/"
DNS_PATH="/system/etc"
CA_PATH="${DNS_PATH}/security/cacerts"
CORE_DIR="${CLASH_DIR}/core"
SCRIPT_DIR="${CLASH_DIR}/scripts"
CONFIG_DIR="${CLASH_DIR}/config"
GEO_PATH="${CLASH_DIR}/Country.mmdb"
SERVICE_DIR="${ADB_DIR}/service.d"
DATA="${MODPATH}/clash"

# installer checker
if [[ $BOOTMODE != true ]]; then
      abort "Error: Install in Magisk Manager."
else
      if [[ "$ARCH" == "arm64" ]]; then
            # Only backup config data
            if [[ -d "${CONFIG_DIR}" ]]; then
                  ui_print "- make backup config data...."
                  mv ${CONFIG_DIR} ${ADB_DIR}/config_bck
            fi
      else  
            abort "Error: Unsupported device."
      fi
fi

# prepare environment
ui_print "- Prepare Clash[Meta] 4 Magisk Execute Environment."
mkdir -p ${CLASH_DIR}
mkdir -p ${CORE_DIR}
mkdir -p ${CONFIG_DIR}
mkdir -p ${SCRIPT_DIR}
mkdir -p ${CLASH_DIR}/run
mkdir -p ${MODPATH}/system/bin
mkdir -p ${MODPATH}${CA_PATH}

# unzip file exclude Meta-Inf
ui_print "- Unzipping file."
unzip -o "${ZIPFILE}" -x 'META-INF/*' -d $MODPATH >&2

if [[ ! -d ${SERVICE_DIR} ]] ; then
  mkdir -p ${SERVICE_DIR}
fi

# move service
mv ${MODPATH}/ClashMeta.sh ${SERVICE_DIR}/

ui_print "- Setup data."
# move scripts
mv "${DATA}/scripts/path.sc" "${SCRIPT_DIR}/"
mv "${DATA}/scripts/clash.inotify" "${SCRIPT_DIR}/"
mv "${DATA}/scripts/clash.service" "${SCRIPT_DIR}/"
mv "${DATA}/scripts/clash.tool" "${SCRIPT_DIR}/"
mv "${DATA}/scripts/clash.tproxy" "${SCRIPT_DIR}/"
mv "${DATA}/scripts/start.sh" "${SCRIPT_DIR}/"
mv "${DATA}/scripts/clash_settings.ini" "${CLASH_DIR}/"
rm -rf "${DATA}/scripts"

# move config
mv "${DATA}/config/_proxies" "${CONFIG_DIR}/"
mv "${DATA}/config/_template" "${CONFIG_DIR}/"
mv "${DATA}/config/account.yaml" "${CONFIG_DIR}/"
mv "${DATA}/config/Country.mmdb" "${CONFIG_DIR}/"
mv "${DATA}/config/GeoIP.dat" "${CONFIG_DIR}/"
mv "${DATA}/config/GeoSite.dat" "${CONFIG_DIR}/"
rm -rf "${DATA}/config"

# move core
mv "${DATA}/core/clash" "${CORE_DIR}/"
mv "${DATA}/core/getcap" "${MODPATH}/system/bin/"
mv "${DATA}/core/setcap" "${MODPATH}/system/bin/"
mv "${DATA}/core/getpcaps" "${MODPATH}/system/bin/"
mv "${DATA}/core/ss" "${MODPATH}/system/bin/"
rm -rf "${DATA}/core"

# move dashboard
unzip ${DATA}/dashboard.zip -d ${CONFIG_DIR} >&2
rm -f ${DATA}/dashboard.zip

# move additional
mv "${DATA}/additional/cacert.pem" "${MODPATH}${CA_PATH}"
mv "${DATA}/additional/resolv.conf" "${MODPATH}${DNS_PATH}/"
rm -rf "${DATA}/additional"

if [[ ! -f "${CLASH_DIR}/packages.list" ]] ; then
    touch ${CLASH_DIR}/packages.list
fi
sleep 1
rm -rf ${DATA}

# replace config backup to config dir if exist
if [[ -d "${ADB_DIR}/config_bck" ]]; then
   ui_print "- applied config data old...."
   rm -rf ${CONFIG_DIR}
   mv ${ADB_DIR}/config_bck ${CONFIG_DIR}
   rm -rf ${ADB_DIR}/config_bck
fi

ui_print "- Setup permission."
set_perm_recursive ${MODPATH} 0 0 0755 0644
set_perm_recursive ${CONFIG_DIR} 0 0 0644 0644
set_perm_recursive ${CONFIG_DIR}/dashboard 0 0 0644 0644
set_perm_recursive ${CORE_DIR} 0 3005 0755 0755
set_perm_recursive ${SCRIPT_DIR} 0 3005 0755 0755

set_perm  ${MODPATH}/system/bin/getcap  0  0  0755
set_perm  ${MODPATH}/system/bin/setcap  0  0  0755
set_perm  ${MODPATH}/system/bin/getpcaps  0  0  0755
set_perm  ${MODPATH}/system/bin/ss  0  0  0755
set_perm  ${MODPATH}${CA_PATH}/cacert.pem 0 0 0644
set_perm  ${MODPATH}${DNS_PATH}/resolv.conf 0 0 0644
set_perm  ${SERVICE_DIR}/ClashMeta.sh  0 0 0755
set_perm  ${CLASH_DIR}/packages.list 0 0 0644
set_perm  ${CLASH_DIR}/clash_settings.ini 0 0 0644
