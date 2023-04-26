#!/system/bin/sh

TAG="cnss_collect_wlan_logs"
BASE_DIR="/data/vivo-common/circulatedlog/debuglogger/connsyslog/fw/"

function dump_sys_service {
    log -t ${TAG} "dumpsys start ${1}"
    dumpsys wifi > "${1}/wifi.dump"
    chmod 774 ${1}/wifi.dump
    dumpsys connectivity > "${1}/connectivity.dump"
    chmod 774 ${1}/connectivity.dump
    #dumpsys netd > "${1}/netd.dump"
    dumpsys wificond > "${1}/wificond.dump"
    chmod 774 ${1}/wificond.dump
    dumpsys network_management > "${1}/network_management.dump"
    chmod 774 ${1}/network_management.dump
    logcat -d > "${1}/logcat.log"
    chmod 774 ${1}/logcat.log
    dmesg > "${1}/dmesg.log"
    chmod 774 ${1}/dmesg.log
}

# Starts here
log -t ${TAG} "Trigger log dump..."
dump_sys_service $BASE_DIR
