#!/system/bin/sh
# Do NOT assume where your module will be located.
# ALWAYS use $MODDIR if you need to know where this script
# and module is placed.
# This will make sure your module will still work
# if Magisk change its mount point in the future
MODDIR=${0%/*}

#  find sdcard
if [ -d /sdcard ] ; then
    sdcardpath=/sdcard
elif [ -d /storage/emulated/0 ] ; then
    sdcardpath=/storage/emulated/0
fi

# set payfixuninstall.log
logfile=/cache/payfixuninstall.log

# create logfile
echo "" > $logfile

# check where chattr is
if [ -f /data/data/com.termux/files/usr/bin/applets/chattr ] ; then
	chattrpath=/data/data/com.termux/files/usr/bin/applets
	echo "Chattr binary found in: $chattrpath" >> $logfile
elif [ -f /system/bin/chattr ] ; then 
	chattrpath=/system/bin
	echo "Chattr binary found in: $chattrpath" >> $logfile
elif [ -f /system/xbin/chattr ] ; then 
	chattrpath=/system/xbin
  	echo "Chattr binary found in: $chattrpath" >> $logfile
else 
	echo "Chattr binary not found" >> $logfile
fi
sleep 2

# on to the main show the database permissions

# stop Google Pay
/system/bin/am force-stop /data/data/com.google.android.apps.walletnfcrel
if [ $? -eq 0 ] ; then
	echo "Google Pay stopped successfully" >> $logfile
else
	echo "Google Pay NOT stopped successfully" >> $logfile
fi
sleep 2

# undo dg.db immutability
$chattrpath/chattr -i /data/data/com.google.android.gms/databases/dg.db
if [ $? -eq 0 ] ; then
	echo "Chattr command completed successfully" >> $logfile
else
	echo "Chattr command FAILED" >> $logfile
fi
sleep 2

# set default 660 permissions on dg.db
/system/bin/chmod 660 /data/data/com.google.android.gms/databases/dg.db
if [ $? -eq 0 ] ; then
	echo "Chmod 660 command completed successfully" >> $logfile
else
	echo "Chmod 660 command FAILED" >> $logfile
fi
sleep 2

# remove /data/adb/service.d/gpay.sh
/system/bin/rm -rf /data/adb/service.d/gpay.sh
if [ $? -eq 0 ] ; then
	echo "Gpay.sh script removed successfully" >> $logfile
else
	echo "Gpay.sh script removal FAILED" >> $logfile
fi
sleep 2

# remove /sdcard/payfixfirstrun.log - this is the onetime runlog from first run of /data/adb/service/gpay.sh
/system/bin/rm -rf $sdcardpath/payfixfirstrun.log
if [ $? -eq 0 ] ; then
	echo "Payfix firstrun log removed successfully" >> $logfile
else
	echo "Payfix firstrun log removal FAILED" >> $logfile
fi

exit
