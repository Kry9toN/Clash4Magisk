#!/system/bin/sh

(
until [ $(getprop sys.boot_completed) -eq 1 ] ; do
  sleep 4
done
/data/adb/clash/scripts/start.sh
)&
