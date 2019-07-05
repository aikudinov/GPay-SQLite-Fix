#!/system/bin/sh
# Do NOT assume where your module will be located.
# ALWAYS use $MODDIR if you need to know where this script
# and module is placed.
# This will make sure your module will still work
# if Magisk change its mount point in the future
MODDIR=${0%/*}

# set logfile variable
logfile="/cache/payfixfirstrun.log"

# set runsql variable :
# 0 = dont run sql commands (440 only edition)
# 1 = run sql commands (full edition)
runsql=1

# checking for existing payfixfirstrun.log file
if [ ! -f $logfile ] ; then
	# create new logfile
	echo "" > $logfile

	if [ $runsql -eq 1 ] ; then
	# check where sqlite is
	if [ -f /data/data/com.termux/files/usr/lib/sqlite3 ] ; then
		sqlpath=/data/data/com.termux/files/usr/lib
		echo "SQLite3 binary found in: $sqlpath" >> $logfile
		echo "" >> $logfile
	elif [ -f /system/bin/sqlite3 ] ; 	then
		sqlpath=/system/bin
		echo "SQLite3 binary found in: $sqlpath" >> $logfile
		echo "" >> $logfile
	elif [ -f /system/xbin/sqlite3 ] ; then
		sqlpath=/system/xbin
		echo "SQLite3 binary found in: $sqlpath" >> $logfile
		echo "" >> $logfile
	else 
		echo "SQLite3 binary not found, please install a SQLite3 binary, without this the fix *may* not work" >> $logfile
		echo "I provide an SQLite3 binary for arm-v7 devices, and links to SQLite3 bonaries for other architectures " >> $logfile
		echo "at https://forum.xda-developers.com/showpost.php?p=79643248&postcount=176" >> $logfile
		echo "" >> $logfile
	fi
	sleep 2
	fi

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
		echo "Chattr -i command completed successfully" >> $logfile
		echo "" >> $logfile
	else
		echo "Chattr command FAILED" >> $logfile
		echo "" >> $logfile
	fi
	sleep 2

	if [ $runsql -eq 1 ] ; then
	# set 777 permissions on dg.db
	chmod 777 /data/data/com.google.android.gms/databases/dg.db
	perms=$(stat -c %a /data/data/com.google.android.gms/databases/dg.db)
	if [ $perms -eq 777 ]; then
		echo "Chmod 777 command completed successfully" >> $logfile
		echo "Permissions reported as: $perms" >> $logfile
		echo "" >> $logfile
	else
		echo "Chmod command FAILED" >> $logfile
		echo "Permissions reported as: $perms" >> $logfile
		echo "" >> $logfile
	fi
	sleep 2
	
	# run sqlite 3 commands on dg.db
	$sqlpath/sqlite3 /data/data/com.google.android.gms/databases/dg.db "update main set c='0' where a like '%attest%';"
	if [ $? -eq 0 ] ; 	then
		echo "SQLite3 command completed successfully" >> $logfile
		echo "" >> $logfile
	else
		echo "SQLite3 command FAILED" >> $logfile
		echo "" >> $logfile
	fi
	sleep 2
	fi
		
	# set 440 permissions on dg.db
	chmod 440 /data/data/com.google.android.gms/databases/dg.db
	perms=$(stat -c %a /data/data/com.google.android.gms/databases/dg.db)
	if [ $perms -eq 440 ] ; then
		echo "Chmod 440 command completed successfully" >> $logfile
		echo "Permissions reported as: $perms" >> $logfile
		echo "" >> $logfile
	else
		echo "Chmod command FAILED" >> $logfile
		echo "Permissions reported as: $perms" >> $logfile
		echo "" >> $logfile
	fi
	sleep 2
	
	# make dg.db file immutable
	$chattrpath/chattr +i /data/data/com.google.android.gms/databases/dg.db
	if [ $? -eq 0 ] ; 	then
		echo "Chattr +i command completed successfully" >> $logfile
		echo "" >> $logfile
	else
		echo "Chattr command FAILED. You would already been warned about this...." >> $logfile
		echo "" >> $logfile
	fi
	
fi
