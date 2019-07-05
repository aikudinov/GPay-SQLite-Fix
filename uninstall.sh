# set payfixuninstall.log
logfile=/cache/payfixuninstall.log

# create logfile
echo "" > $logfile

# check where chattr is
if [ -f /data/data/com.termux/files/usr/bin/applets/chattr ] ; then
	chattrpath=/data/data/com.termux/files/usr/bin/applets
	echo "Chattr binary found in: $chattrpath" >> $logfile
	echo "" >> $logfile
elif [ -f /system/bin/chattr ] ; then 
	chattrpath=/system/bin
	echo "Chattr binary found in: $chattrpath" >> $logfile
	echo "" >> $logfile
elif [ -f /system/xbin/chattr ] ; then 
	chattrpath=/system/xbin
  	echo "Chattr binary found in: $chattrpath" >> $logfile
	echo "" >> $logfile
else 
	echo "Chattr binary not found, BusyBox is needed to provide chattr, which is used to make the database immutable" >> $logfile
	echo "Without chattr this fix *may* not work, though people report that the fix works fine for them without using"  >> $logfile
	echo "chattr. However, if you want the full fix script to run as designed, please install BusyBox for Android NDK from" >> $logfile 
	echo  "the Magisk Repo" >> $logfile
	echo "" >> $logfile
fi
sleep 2

# on to the main show............

# stop Google Pay
am force-stop /data/data/com.google.android.apps.walletnfcrel
if [ $? -eq 0 ] ; then
	echo "Google Pay stopped successfully" >> $logfile
	echo "" >> $logfile
else
	echo "Google Pay NOT stopped successfully" >> $logfile
	echo "" >> $logfile
fi
sleep 2

# undo dg.db immutability
$chattrpath/chattr -i /data/data/com.google.android.gms/databases/dg.db
if [ $? -eq 0 ] ; then
	echo "Chattr command completed successfully" >> $logfile
	echo "" >> $logfile
else
	echo "Chattr command FAILED" >> $logfile
	echo "" >> $logfile
fi
sleep 2

# set default 660 permissions on dg.db
chmod 660 /data/data/com.google.android.gms/databases/dg.db
perms=$(stat -c %a /data/data/com.google.android.gms/databases/dg.db)
if [ $perms -eq 660 ] ; then
	echo "Chmod 660 command completed successfully" >> $logfile
	echo "Permissions reported as: $perms" >> $logfile
	echo "" >> $logfile
else
	echo "Chmod 660 command FAILED" >> $logfile
	echo "Permissions reported as: $perms" >> $logfile
	echo "" >> $logfile
fi
sleep 2

# remove /data/adb/service.d/gpay.sh
rm -rf /data/adb/service.d/gpay.sh
if [ $? -eq 0 ] ; then
	echo "Gpay.sh script removed successfully" >> $logfile
	echo "" >> $logfile
else
	echo "Gpay.sh script removal FAILED" >> $logfile
	echo "" >> $logfile
fi
sleep 2

# remove /cache/payfixfirstrun.log - this is the onetime runlog from first run of /data/adb/service/gpay.sh
rm -rf /cache/payfixfirstrun.log
if [ $? -eq 0 ] ; then
	echo "Payfix firstrun log removed successfully" >> $logfile
	echo "" >> $logfile
else
	echo "Payfix firstrun log removal FAILED" >> $logfile
	echo "" >> $logfile
fi
