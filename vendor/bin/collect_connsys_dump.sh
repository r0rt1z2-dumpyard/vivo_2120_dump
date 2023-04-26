#!/vendor/bin/sh

TAG="collect_connsys_dump"
DUMP_HASH_CMM="// ## Firmware version\n\
// ## ----------------\n\
// ## VIVO|11102016|xiaolei.du|MTK_1.0.1\n\
// ## Description:  src_file_unknown.c:995:WLAN: (0x11102016): 0x99999\n\
// ## Arguments:    "

# Starts here
log -t ${TAG} "Start ${1} connsys dump..."

if [ "$1" == "clear" ]; then
    rm -rf /data/vendor/connsyslog/wifi/*
    return
fi

# Reset last dump path
setprop "vendor.wifidump.prop.last_dump_path" ""

timestamp=`date '+%Y_%m_%d_%H_%M_%S'`
# Copy dumps to cache dir
dump_dir="moredump_${timestamp}"
mkdir /data/vendor/connsyslog/wifi/${dump_dir}
mkdir /data/vendor/connsyslog/wifi/${dump_dir}/bt
mv /data/vendor/connsyslog/wifi/combo_t32* /data/vendor/connsyslog/wifi/${dump_dir}
mv /data/vendor/connsyslog/bt/* /data/vendor/connsyslog/wifi/${dump_dir}/bt/
# Calculate hash and write hash file
for file in `ls /data/vendor/connsyslog/wifi/${dump_dir}/*.xml`; do
    md5=($(md5sum ${file}))
    #log -t $TAG "md5sum: ${md5}"
    #log -t $TAG "${DUMP_HASH_CMM}${md5}"
    echo "${DUMP_HASH_CMM}${md5}" > /data/vendor/connsyslog/wifi/${dump_dir}/moredump_${timestamp}.cmm
done
# Save dmesg
dmesg > /data/vendor/connsyslog/wifi/${dump_dir}/kernel.log
# Save wifi fw log
cp -rf /data/debuglogger/connsyslog/fw/CsLog*/*.clog /data/vendor/connsyslog/wifi/${dump_dir}
cp -rf /data/debuglogger/connsyslog/fw/CsLog*/*.clog.curf /data/vendor/connsyslog/wifi/${dump_dir}
tar_file_path=/data/vendor/connsyslog/wifi/moredump_${timestamp}.tar.gz
tar -czf $tar_file_path -C /data/vendor/connsyslog/wifi/ .
chmod 777 $tar_file_path
setprop "vendor.wifidump.prop.last_dump_path" ${tar_file_path}
#/system/bin/am broadcast -a "com.vivo.intent.action.CLOUD_DIAGNOSIS" --ei "attr" 3 --ei "module" 3300 --es "data" "{\"moduleid\":\"3300\",\"eventId\":\"00059|012\",\"logpath\":\"${tar_file_path}\"}" com.bbk.iqoo.logsystem
