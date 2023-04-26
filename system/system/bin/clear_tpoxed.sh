#!/system/bin/sh
#
#


if [ -f "/cache/flag_after_ota" ]; then
  log -t clear_tpoxed "this is the first boot since the upgrade."

  prepare_tpoxed=$(getprop persist.vivo.prepare_tpoxed)
  log -t clear_tpoxed "prepare_tpoxed is ${prepare_tpoxed}"

  # restore file status even if prepare_tpoxed.sh not prepared
  restorecon /data/.dex2oat_cache && log -t clear_tpoxed "succeeded to restore tpoxed dir SELinux status." || log -t clear_tpoxed "failed to restore tpoxed dir SELinux status."
  chmod 0777 /data/.dex2oat_cache && log -t clear_tpoxed "succeeded to restore tpoxed dir RWX status." || log -t clear_tpoxed "failed to restore tpoxed dir RWX status."
  restorecon /data/.dex2oat_cache/* && log -t clear_tpoxed "succeeded to restore tpoxed file SELinux status." || log -t clear_tpoxed "failed to restore tpoxed file SELinux status."
  chmod 0777 /data/.dex2oat_cache/* && log -t clear_tpoxed "succeeded to restore tpoxed file RWX status." || log -t clear_tpoxed "failed to restore tpoxed file RWX status."

  # deal with 'tinker'
  tinker_0_flag=$(ls /data/.dex2oat_cache/)
  if [ -z "${tinker_0_flag}" ]; then
    rm -rf /data/user/0/com.tencent.mm/tinker && log -t clear_tpoxed "succeeded to delete 0 com.tencent.mm tinker." || log -t clear_tpoxed "failed to delete 0 com.tencent.mm tinker."
  fi

  tinker_999_flag=$(ls /data/.dex2oat_cache/)
  if [ -z "${tinker_999_flag}" ]; then
    # TODO: deletion might actually failed here, for '/data/user/999' is still encrypted
    rm -rf /data/user/999/com.tencent.mm/tinker && log -t clear_tpoxed "succeeded to delete 999 com.tencent.mm tinker." || log -t clear_tpoxed "failed to delete 999 com.tencent.mm tinker."
  fi

  prepare_tpoxed_num_dex=$(getprop persist.vivo.prepare_tpoxed_num_dex)
  num=$(ls /data/.dex2oat_cache/*.odex | wc -l)
  setprop persist.vivo.prepare_tpoxed_num_cache_dex ${num}
  setprop persist.vivo.prepare_tpoxed_num_cache_rate "${num}/${prepare_tpoxed_num_dex}"
  num=$(ls /data/.dex2oat_cache/*.odex | awk -F'@' '{print $5}' | sort | uniq | wc -l)
  setprop persist.vivo.prepare_tpoxed_num_cache_pkg ${num}
  setprop persist.vivo.prepare_tpoxed_internal last
  setprop persist.vivo.prepare_tpoxed last
else
  DEX2OAT_CACHE_DIR="/data/.dex2oat_cache"
  if [ -d "${DEX2OAT_CACHE_DIR}" ]; then
    rm -rf ${DEX2OAT_CACHE_DIR} && log -t clear_tpoxed "succeeded to clear tpoxed." || log -t clear_tpoxed "failed to clear tpoxed."
  else
    log -t clear_tpoxed "tpoxed does not exist."
  fi

  setprop persist.vivo.prepare_tpoxed_num_cache_dex 0
  setprop persist.vivo.prepare_tpoxed_num_cache_pkg 0
  setprop persist.vivo.prepare_tpoxed_internal clear
  setprop persist.vivo.prepare_tpoxed clear
fi
