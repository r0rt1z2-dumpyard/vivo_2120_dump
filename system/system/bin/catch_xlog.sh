#!system/bin/sh

LOG_TAG="wdebug"
LOG_NAME="${0}:"

logi ()
{
        /system/bin/log -t $LOG_TAG -p i "$LOG_NAME $@"
}

logi "start wdebug"
dateNow=$(date +%Y%m%d)
echo $dateNow
dataXlogFile=/data/data/com.tencent.mm/files/xlog/MM_$dateNow.xlog
echo $dataXlogFile

maxsize=$((50*1024*1024))

filesize=`ls -l $dataXlogFile | awk '{ print $5 }'`
echo $filesize
echo $maxsize

if [ $filesize -gt $maxsize ]
then
    logi "wdebug is too big,skip to catch"
elif [ -f $dataXlogFile ]
then
    logi "xlog is exist"
    tar -cvf  /data/local/tmp/.wdebug.tar.gz  $dataXlogFile
    chmod 777 /data/local/tmp/.wdebug.tar.gz
else
   logi "xlog is not exit"
   echo "xlog is not exist"
fi
setprop sys.logsystem.upload.wdebug 0
logi "stop wdebug"
