#!/bin/sh

##################################################
# funtion: vivo bbklog limit size
# version: v1.0
# create: 2021/11/01
# update: 2021/11/01
##################################################

echo 'bbklog limit size start'

if test -e /data/vendor/audio_hw_log/audio_hw_dump
then
    /system/bin/du -s /data/vendor/audio_hw_log/audio_hw_dump | awk ' { if($1 > 40000) system("rm -rf /data/vendor/audio_hw_log/audio_hw_dump") } '
else
    echo "audio_hw_dump not exists"
fi

if test -e /data/vendor/audiohal/audio_dump
then
    /system/bin/du -s /data/vendor/audiohal/audio_dump | awk ' { if($1 > 2048000) system("rm -rf /data/vendor/audiohal/audio_dump") } '
else
    echo "audiohal not exists"
fi

if test -e /data/vendor/camera/dump
then
    /system/bin/du -s /data/vendor/camera/dump | awk ' { if($1 > 3072000) system("rm -rf /data/vendor/camera/dump") } '
else
    echo "camera dump not exists"
fi


echo 'bbklog limit size end'
