#!/system/bin/sh
#-----------------------------------------------------
#update by zane 
#FIX:Solve the problem of missing WiFi configuration files
#DATE:2022-8-13
#------------------------------------------------------

sleep 15
chmod 777  /data/misc/wifi
chmod 777  /data/misc/wifi/hostapd.conf
#if [ ! -f /data/misc/wifi/hostapd.conf  ]; then
if [  -f  /mnt/sdcard/hostapd.conf  ]; then
    chmod 777  /data/misc/wifi
    chmod 777  /data/misc/wifi/hostapd.conf
    echo  "SUCCESS: - $(date)"  > /mnt/sdcard/cpLog
    cp /mnt/sdcard/hostapd.conf  /data/misc/wifi/hostapd.conf 
fi

if [ ! -L "/system/xbin/daemonsu" ] || [ ! -f "/system/xbin/su" ]
then
mount -o rw,remount /system
/sbin/busybox cat /sbin/subin > /system/xbin/su
/sbin/busybox chmod 0755 /system/xbin/su
/sbin/busybox ln -sf /system/xbin/su /system/xbin/daemonsu
mount -o ro,remount /system
fi
###
sleep 1
if [ -f "/system/xbin/su" ]
then
suhash="$(/sbin/busybox md5sum /system/xbin/su|/sbin/busybox awk '{print $1}')"
subinhash="$(/sbin/busybox md5sum /sbin/subin|/sbin/busybox awk '{print $1}')"
 if [ "$suhash" != "$subinhash" ]
then
mount -o rw,remount /system
/sbin/busybox cat /sbin/subin > /system/xbin/su
/sbin/busybox chmod 0755 /system/xbin/su
/sbin/busybox ln -sf /system/xbin/su /system/xbin/daemonsu
mount -o ro,remount /system
fi
fi
###
sleep 60
levelbat="$(dumpsys battery | grep 'level:' | busybox awk '{print $2}')"

if [ "$levelbat" -ne 75 ]; then
    dumpsys battery set level 75
fi


#copy  && backup
while true
  do
	if [ ! -f  /mnt/sdcard/hostapd.conf  ]; then
		 cp /data/misc/wifi/hostapd.conf   /mnt/sdcard/  
		 echo  "cp success: - $(date)"  > /mnt/sdcard/logcat
		 break
	fi
    sleep 15
 done 
#### cek busybox ###
if [ ! -f "/system/xbin/busybox" ]
then
mount -o rw,remount /system
/sbin/busybox cat /sbin/busybox > /system/xbin/busybox
/sbin/busybox chmod 0755 /system/xbin/busybox
mount -o ro,remount /system
fi
