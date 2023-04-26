#!/system/bin/sh

function SetKeysValues()
{
    inifile="$1"
    section="$2"
    if [ $# -ne 2 ] || [ ! -f ${inifile} ]; then
        log -t vivo_check "ini file [${inifile}]!"
    else
        k_values=$(sed -n '/\['$section'\]/,/^$/p' $inifile|grep -Ev '\[|\]|^$')
        for kv in ${k_values}
        do
            key=$(echo ${kv%%=*})
            value=$(echo ${kv##*=})
            log -t vivo_check "key=$key, value=$value, will be set."
            setprop $key $value && log -t vivo_check "set success!"
        done
    fi
}

log -t vivo_check "will check and set google property for ex."
CHECK_INI="/data/vivo-apps/google_ex_name.ini"
OEM_NAME=`getprop ro.vivo.oem.name`
if [ ! -f "$CHECK_INI" ] || [ ! -n "$OEM_NAME" ]; then
    log -t vivo_check "can not get CHECK_INI:$CHECK_INI or OEM_NAME:$OEM_NAME"
else
    SetKeysValues $CHECK_INI $OEM_NAME
fi
