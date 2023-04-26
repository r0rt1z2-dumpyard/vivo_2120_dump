#!/bin/sh

##################################################
# funtion: vivo bbklog clear log
# version: v1.0
# create: 2021/11/01
# update: 2021/11/01
##################################################

echo 'bbklog clear log start'

if test -e /data/vendor/audio_hw_log/audio_hw_dump
then
    /system/bin/find /data/vendor/audio_hw_log/audio_hw_dump -type f -mmin +$1 -exec rm -rf {} \;
else
    echo "audio_hw_dump not exists"
fi

if test -e /data/vendor/audiohal/audio_dump
then
    /system/bin/find /data/vendor/audiohal/audio_dump -type f -mmin +$1 -exec rm -rf {} \;
else
    echo "audiohal not exists"
fi

if test -e /data/vendor/camera/dump
then
    /system/bin/find /data/vendor/camera/dump -type f -mmin +$1 -exec rm -rf {} \;
else
    echo "camera dump not exists"
fi

echo 'bbklog clear log end'
