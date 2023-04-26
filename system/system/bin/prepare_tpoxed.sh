#!/system/bin/sh
#
# Copyright chenyuqin@vivo
#
# latest update: 08/07/2020
#
#   prepare RECOVERY-DEXOPT environment
#


DEX2OAT_CACHE_DIR="/data/.dex2oat_cache"


# TODO: take xxxx-conditions into consideration, to make sure 'prepare_tpoxed' correct (while for 'prepared', it's enough here)
prepare_tpoxed_internal=$(getprop persist.vivo.prepare_tpoxed_internal)
prepare_tpoxed_record=$(getprop persist.vivo.prepare_tpoxed_record)
if [ "${prepare_tpoxed_internal}" == "prepared" ]; then
  record=$(md5sum /data/system/package-dex-usage.list | awk -F ' ' '{print $1}')
  if [ "${prepare_tpoxed_record}" == "${record}" ]; then
    log -t prepare_tpoxed "go ahead for already prepared."
    setprop persist.vivo.prepare_tpoxed prepared
    exit 0
  fi
  # let's update (while perhaps corrupt one file)
fi
setprop persist.vivo.prepare_tpoxed_internal running
setprop persist.vivo.prepare_tpoxed running

# rm -rf ${DEX2OAT_CACHE_DIR}
mkdir -p ${DEX2OAT_CACHE_DIR}

data_remain=$(df | grep /dev/block/ | grep /data | awk '{print $4}')
if [ "${data_remain}" -ge 5242880 ]; then
  log -t prepare_tpoxed "going to prepare."

  # 1st read dex files
  dex_files=""
  lines=$(cat /data/system/package-dex-usage.list)
  for line in ${lines}
  do
    if [[ "${line}" == \#* ]]; then
      dex_files="${dex_files} ${line#*#}"
    fi
  done
  dex_files_sorted=""
  lines=$(cat /data/system/package-usage-sort.list)
  for line in ${lines}
  do
    for dex_file in ${dex_files}
    do
      # TODO: be more accurate
      if [[ ${dex_file} == */${line}/* ]]; then
        dex_files_sorted="${dex_files_sorted} ${dex_file}"
      fi
    done
  done
  remain=""
  for dex_file in ${dex_files}
  do
    found=0
    for dext_file_another in ${dex_files_sorted}
    do
      if [ "${dex_file}" == "${dext_file_another}" ]; then
        found=1
        break
      fi
    done
    if [ "${found}" == "0" ]; then
      remain="${remain} ${dex_file}"
    fi
  done
  dex_files_sorted="${dex_files_sorted} ${remain}"

  # 2nd populate { dex / odex / vdex / prof } source files (deeper first)
  dex_num=0
  src_files=""
  for dex_file in ${dex_files_sorted}
  do
    # { A / B / C } = { dir-name / file-name / file-name (without extension) }
    A=$(dirname  ${dex_file})
    B=$(basename ${dex_file})
    C=${B%.*}
    P=""

    # ODEX / VDEX
    ISA="arm arm64"
    for I in ${ISA}
    do
      if [ -f "${A}/oat/${I}/${C}.odex" ]; then
        P="${P} ${A}/oat/${I}/${C}.odex ${A}/oat/${I}/${C}.vdex"
        let dex_num=dex_num+1
      fi
    done

    # PROFILE
    if [ -f "${A}/oat/${B}.prof" ]; then
       P="${P} ${A}/oat/${B}.prof"
    else
      if [ -f "${A}/oat/${B}.cur.prof" ]; then
        P="${P} ${A}/oat/${B}.cur.prof"
      fi
    fi

    # DEX
    if [ -f "${dex_file}" ]; then
      P="${P} ${dex_file}"
    fi

    src_files="${src_files} ${P}"
  done
  setprop persist.vivo.prepare_tpoxed_num_dex ${dex_num}

  # finally COPY (TODO: try make it incremental one)
  for src_file in ${src_files}
  do
    dst_file=${src_file#*/data/}
    dst_dire=$(dirname ${DEX2OAT_CACHE_DIR}/${dst_file})
    if [  ! -d "${dst_dire}" ]; then
      mkdir -p "${dst_dire}"
    fi
    cp -a ${src_file} ${DEX2OAT_CACHE_DIR}/${dst_file}
  done

  record=$(md5sum /data/system/package-dex-usage.list | awk -F ' ' '{print $1}')
  setprop persist.vivo.prepare_tpoxed_record ${record}
  setprop persist.vivo.prepare_tpoxed_internal prepared
  setprop persist.vivo.prepare_tpoxed prepared
else
  log -t prepare_tpoxed "skipped for not enough space on /data: current $data_remain."
  setprop persist.vivo.prepare_tpoxed_internal skipped
  setprop persist.vivo.prepare_tpoxed skipped
fi
