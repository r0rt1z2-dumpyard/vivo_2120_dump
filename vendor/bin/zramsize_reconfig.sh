#!/vendor/bin/sh

# use for mtk and samsung

# check osversion >=Funtouch11.5/>=vos2.1
function zwb_support_osversion() {
	Version=$1
	# products for china
	if [ `echo $Version 5.0  | awk '{print($1>$2)?"1":"0"}'` -eq "1" ]; then
		if [ `echo $Version 11.5 | awk '{print($1<$2)?"1":"0"}'` -eq "1" ]; then
			return 1
		fi
	# products for export
	else
		if [ `echo $Version 2.1 | awk '{print($1<$2)?"1":"0"}'` -eq "1" ]; then
			return 1
		fi
	fi
	return 0
}

# for first version < 12.0, default close
function zwb_default_osversion() {
	Version=$1
	# products for china
	if [ `echo $Version 5.0  | awk '{print($1>$2)?"1":"0"}'` -eq "1" ]; then
		if [ `echo $Version 12 | awk '{print($1<$2)?"1":"0"}'` -eq "1" ]; then
			return 1
		fi
	# products for export
	else
		if [ `echo $Version 2.1 | awk '{print($1<$2)?"1":"0"}'` -eq "1" ]; then
			return 1
		fi
	fi
	return 0
}

function zwb_support() {
	if [ ! -f /sys/block/zram0/backing_dev ]; then
		return 1
	fi

	if [ "$MemSizeKB" -le "2097152" ];then
		return 1
	fi

	ROMSizeKB=`df -k | grep /data$ | awk '{print $2}'`
	if [ "$ROMSizeKB" -le "33554432" ];then
		return 1
	fi

	OSVersion=`getprop ro.vivo.os.version`
	return `zwb_support_osversion $OSVersion`
}

function zwb_version() {
	ZWBVersion=`cat /sys/block/zram0/wb`
	if [ "$ZWBVersion" == "" ]; then
		ZWBVersion=1
	else
		# RAM>=6G, ROM<=64G, keep v1
		if [ "$MemSizeKB" -gt "4194304" ] && [ "$ROMSizeKB" -lt "67108864" ]; then
			ZWBVersion=1
		elif [ "$MemSizeKB" -lt "3145728" ]; then
			ZWBVersion=1
		fi
	fi
}

function zwb_size_v1() {
	if [ $zRamSizeMB -ge 4096 ]; then
		BDSizeMB=3072
		ZWBV1Special=1
	elif [ $zRamSizeMB -ge 3072 ]; then
		BDSizeMB=1024
	elif [ $zRamSizeMB -ge 1536 ]; then
		BDSizeMB=512
	else
		BDSizeMB=`expr $zRamSizeMB / 3`
	fi
}

function zwb_size_v2() {
	if [ $zRamSizeMB -ge 4096 ]; then
		BDSizeMB=4096
		ZWBV2Special=1
	elif [ $zRamSizeMB -ge 3072 ]; then
		BDSizeMB=2048
		ZWBV2Special=2
	elif [ $zRamSizeMB -ge 2048 ]; then
		BDSizeMB=1024
	else
		BDSizeMB=`expr $zRamSizeMB / 3`
	fi
}

function zwb_size_v3() {
	if [ $zRamSizeMB -ge 4096 ]; then
		BDSizeMB=4096
	elif [ $zRamSizeMB -ge 3072 ]; then
		BDSizeMB=2048
	elif [ $zRamSizeMB -ge 2048 ]; then
		BDSizeMB=1024
	else
		BDSizeMB=`expr $zRamSizeMB / 3`
	fi
	CachePage=`expr \( $BDSizeMB / 2 + $zRamSizeMB \) \* 256`
}

function zwb_size()
{
	if [ "$ZWBVersion" -eq "1" ]; then
		zwb_size_v1
	elif [ "$ZWBVersion" -eq "2" ]; then
		zwb_size_v2
	elif [ "$ZWBVersion" -eq "3" ]; then
		zwb_size_v3
	fi
	setprop persist.vendor.vivo.zramwb.size $BDSizeMB
}

function zwb_user_chioce() {
	# user choice
	ZWBTriggerUser=`getprop persist.vendor.vivo.zramwb.enable`
	if [ "$ZWBTriggerUser" == "" ]; then
		ZWBTriggerUser=`getprop ro.vivo.zramwb.default`
		if [ "$ZWBTriggerUser" != "1" ] && [ "$ZWBTriggerUser" != "0" ]; then
			OSFirstVersion=`getprop ro.vivo.fist.os.version`
			if [ "$OSFirstVersion" == "" ] || ! zwb_default_osversion $OSFirstVersion ; then
				ZWBTriggerUser=0
			else
				ZWBTriggerUser=1
			fi
		fi
	fi
}

function zwb_storage_chioce() {
	ZWBTrigger=$ZWBTriggerUser
	if [ "$ZWBTrigger" == "0" ]; then
		return
	fi

	# get life_time from ufs or emmc
	if [ -d /sys/ufs ]; then
		life_time_a=`cat /sys/ufs/life_time_a`
		life_time_b=`cat /sys/ufs/life_time_b`
	else
		life_time_a=`cat /sys/block/mmcblk0/device/dev_left_time_a`
		life_time_b=`cat /sys/block/mmcblk0/device/dev_left_time_b`
	fi

	# memory life > 5 then close zram writeback
	if [ "$life_time_a" != "0x00" ] && [ "$life_time_a" != "0x01" ] && [ "$life_time_a" != "0x02" ] && [ "$life_time_a" != "0x03" ] && [ "$life_time_a" != "0x04" ] && [ "$life_time_a" != "0x05" ]; then
		ZWBTrigger=0
	fi
	if [ "$life_time_b" != "0x00" ] && [ "$life_time_b" != "0x01" ] && [ "$life_time_b" != "0x02" ] && [ "$life_time_b" != "0x03" ] && [ "$life_time_b" != "0x04" ] && [ "$life_time_b" != "0x05" ]; then
		ZWBTrigger=0
	fi
}

# ZWBTriggerUser & ZWBTrigger
function zwb_chioce() {
	zwb_user_chioce
	zwb_storage_chioce
}

function zwb_storage_check() {
	ROMFreeSizeKB=`df -k | grep /data$ | awk '{print $4}'`
	if [ "$ROMSizeKB" -lt "33554432" ]; then
		return 1
	elif [ "$ROMSizeKB" -lt "67108864" ]; then
		if [ "$ROMFreeSizeKB" -lt "10240000" ]; then
			return 1
		fi
	elif [ "$ROMSizeKB" -lt "134217728" ]; then
		if [ "$ROMFreeSizeKB" -lt "16384000" ]; then
			return 1
		fi
	elif [ "$ROMSizeKB" -lt "536870912" ]; then
		if [ "$ROMFreeSizeKB" -lt "25600000" ]; then
			return 1
		fi
	else
		return 1
	fi

	return 0
}

function zwb_create_file() {
	BDPath="/data/vendor/swap/zram"
	if [ "$ZWBTriggerUser" -eq "0" ]; then
		rm $BDPath
		return
	fi

	FileSizeB=`stat -c "%s" $BDPath`
	BDSizeB=`expr $BDSizeMB \* 1048576`
	if [ "$BDSizeB" == "$FileSizeB" ] || ! zwb_storage_check ; then
		return
	fi

	is_f2fs1=`df -t f2fs | grep /data$`
	is_f2fs2=`mount -r -t f2fs | grep " /data "`
	if [ "$is_f2fs1" == "" ] && [ "$is_f2fs2" == "" ]; then
		dd if=/dev/zero of=$BDPath bs=1m count=$BDSizeMB
	else
		touch $BDPath
		f2fs_io pinfile set $BDPath
		fallocate -l $BDSizeB -o 0 $BDPath
	fi
}

function zwb_v1_special() {
	if [ "$ZWBV1Special" -ne "1" ]; then
		return
	fi
	BDSizeMB=1536
}

function zwb_v2_special() {
	if [ "$ZWBV2Special" == "1" ]; then
		BDSizeMB=2048
	elif [ "$ZWBV2Special" == "2" ]; then
		BDSizeMB=1536
	fi
}

function zwb_sp() {
	if [ "$ZWBVersion" -eq "1" ]; then
		zwb_v1_special
	elif [ "$ZWBVersion" -eq "2" ]; then
		zwb_v2_special
	fi
}

function zwb_core() {
	zwb_sp
	if [ "$ZWBTrigger" -eq "1" ]; then
		zRamSizeMB=`expr $BDSizeMB + $zRamSizeMB`
		echo $BDPath > /sys/block/zram0/backing_dev
	fi
}

function zwb_parameter_v1() {
	BDSizePage=`expr $BDSizeMB \* 256`
	if [ "$ZWBV1Special" == "1" ]; then
		echo $BDSizePage > /sys/block/zram0/zram_wb/bd_size_limit
	fi

	# bd_reclaim_min should be min watermark diff at least
	if [ -f /sys/block/zram0/zram_wb/bd_reclaim_min ]; then
		# (1536 << 10 / 4) * 2%
		if [ "$MemSizeKB" -lt "3145728" ]; then
			echo 7900 > /sys/block/zram0/zram_wb/bd_reclaim_min
		# (2048 << 10 / 4) * 2%
		elif [ "$MemSizeKB" -lt "4194304" ]; then
			echo 10500 > /sys/block/zram0/zram_wb/bd_reclaim_min
		# (3072 << 10 / 4) * 2%
		elif [ "$MemSizeKB" -lt "6291456" ];then
			echo 15800 > /sys/block/zram0/zram_wb/bd_reclaim_min
		# (4096 << 10 / 4) * 2%
		else
			echo 24000 > /sys/block/zram0/zram_wb/bd_reclaim_min
		fi
	fi

	echo 0 > /sys/block/zram0/zram_wb/dswappiness_enable
}

function zwb_parameter_v2() {
	BDSizePage=`expr $BDSizeMB \* 256`
	if [ "$ZWBV2Special" == "1" ] || [ "$ZWBV2Special" == "2" ]; then
		echo $BDSizePage > /sys/block/zram0/zram_wb/bd_size_limit
	fi

	if [ "$MemSizeKB" -lt "4194304" ]; then
		echo 80 > /sys/block/zram0/zram_wb/dswappiness_low
		echo 110 > /sys/block/zram0/zram_wb/dswappiness_high
	elif [ "$MemSizeKB" -lt "6291456" ]; then
		echo 80 > /sys/block/zram0/zram_wb/dswappiness_low
		echo 120 > /sys/block/zram0/zram_wb/dswappiness_high
	else
		echo 60 > /sys/block/zram0/zram_wb/dswappiness_low
		echo 80 > /sys/block/zram0/zram_wb/dswappiness_high
	fi
}

function zwb_parameter_v3() {
	echo $CachePage > /sys/block/zram0/zram_wb/cache
}

function zwb_parameter() {
	if [ ! -d /sys/block/zram0/zram_wb ]; then
		return
	fi

	if [ "$ZWBVersion" -eq "1" ]; then
		zwb_parameter_v1
	elif [ "$ZWBVersion" -eq "2" ]; then
		zwb_parameter_v2
	elif [ "$ZWBVersion" -eq "3" ]; then
		zwb_parameter_v3
	fi
}

function zwb_init() {
	if ! zwb_support ; then
		return
	fi

	zwb_version
	zwb_size
	zwb_chioce
	zwb_create_file
	zwb_core
}

function zram_size_init() {
	MemSizeKB=`cat /proc/meminfo | awk '/MemTotal/ {print $2}'`
	if [ "$MemSizeKB" -lt "3145728" ];then
		zRamSizeMB=1536
	elif [ "$MemSizeKB" -lt "4194304" ];then
		zRamSizeMB=2048
	elif [ "$MemSizeKB" -lt "6291456" ];then
		zRamSizeMB=3072
	else
		zRamSizeMB=4096
	fi
}

function zram_init() {
	# reset zram
	swapoff /dev/block/zram0
	echo 1 > /sys/block/zram0/reset

	zram_size_init
	zwb_init
	echo "$zRamSizeMB""M" > /sys/block/zram0/disksize
	zwb_parameter

	mkswap /dev/block/zram0
	swapon /dev/block/zram0
}

if [ ! -d /sys/block/zram0 ];then
	exit
fi

zram_init

