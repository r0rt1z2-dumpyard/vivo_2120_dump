#!/system/bin/sh
#
#


USABLE_PROFILES_DIR="/data/misc/usable-profiles"
if [ -d "${USABLE_PROFILES_DIR}" ]; then
  rm -rf ${USABLE_PROFILES_DIR} && log -t clear_artpp "succeeded to clear artpp." || log -t clear_artpp "failed to clear artpp."
else
  log -t clear_artpp "artpp does not exist."
fi

USABLE_DEXMETADATA_DIR="/data/misc/dexmetadata"
if [ -d "${USABLE_DEXMETADATA_DIR}" ]; then
  rm -rf ${USABLE_DEXMETADATA_DIR} && log -t clear_artpp "succeeded to clear dex metadata." || log -t clear_artpp "failed to clear dex metadata."
else
  log -t clear_artpp "dex metadata dir does not exist."
fi

