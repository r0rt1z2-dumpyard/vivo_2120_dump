#!/bin/bash

cat boot.img.* 2>/dev/null >> boot.img
rm -f boot.img.* 2>/dev/null
cat product/app/Maps/Maps.apk.* 2>/dev/null >> product/app/Maps/Maps.apk
rm -f product/app/Maps/Maps.apk.* 2>/dev/null
cat product/app/Gmail2/Gmail2.apk.* 2>/dev/null >> product/app/Gmail2/Gmail2.apk
rm -f product/app/Gmail2/Gmail2.apk.* 2>/dev/null
cat product/app/TrichromeLibrary/TrichromeLibrary.apk.* 2>/dev/null >> product/app/TrichromeLibrary/TrichromeLibrary.apk
rm -f product/app/TrichromeLibrary/TrichromeLibrary.apk.* 2>/dev/null
cat product/priv-app/GmsCoreGo/GmsCoreGo.apk.* 2>/dev/null >> product/priv-app/GmsCoreGo/GmsCoreGo.apk
rm -f product/priv-app/GmsCoreGo/GmsCoreGo.apk.* 2>/dev/null
cat bootimg/01_dtbdump_MT6765.dtb.* 2>/dev/null >> bootimg/01_dtbdump_MT6765.dtb
rm -f bootimg/01_dtbdump_MT6765.dtb.* 2>/dev/null
cat system/system/app/VivoThemeRes_T1/VivoThemeRes_T1.apk.* 2>/dev/null >> system/system/app/VivoThemeRes_T1/VivoThemeRes_T1.apk
rm -f system/system/app/VivoThemeRes_T1/VivoThemeRes_T1.apk.* 2>/dev/null
cat system/system/app/VivoThemeRes/VivoThemeRes.apk.* 2>/dev/null >> system/system/app/VivoThemeRes/VivoThemeRes.apk
rm -f system/system/app/VivoThemeRes/VivoThemeRes.apk.* 2>/dev/null
cat system/system/framework/vivo-res.apk.* 2>/dev/null >> system/system/framework/vivo-res.apk
rm -f system/system/framework/vivo-res.apk.* 2>/dev/null
cat system/system/priv-app/SystemUI/SystemUI.apk.* 2>/dev/null >> system/system/priv-app/SystemUI/SystemUI.apk
rm -f system/system/priv-app/SystemUI/SystemUI.apk.* 2>/dev/null
cat system/system/priv-app/Settings/Settings.apk.* 2>/dev/null >> system/system/priv-app/Settings/Settings.apk
rm -f system/system/priv-app/Settings/Settings.apk.* 2>/dev/null
cat recovery.img.* 2>/dev/null >> recovery.img
rm -f recovery.img.* 2>/dev/null
