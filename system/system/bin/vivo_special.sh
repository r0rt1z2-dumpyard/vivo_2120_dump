#!/system/bin/sh
#
#


if [ -f "/cache/flag_after_ota" ]; then
  tinker_999_flag=$(ls /data/.dex2oat_cache/)
  if [ -z ${tinker_999_flag} ]; then
    rm -rf /data/user/999/com.tencent.mm/tinker && log -t vivo_special "succeeded to delete 999 com.tencent.mm tinker." || log -t vivo_special "failed to delete 999 com.tencent.mm tinker."
  fi
fi
