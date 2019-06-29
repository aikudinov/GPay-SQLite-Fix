#!/system/bin/sh
# Do NOT assume where your module will be located.
# ALWAYS use $MODDIR if you need to know where this script
# and module is placed.
# This will make sure your module will still work
# if Magisk change its mount point in the future
MODDIR=${0%/*}

# Check where sqlite is
if [ -f /data/data/com.termux/files/usr/lib/sqlite3 ]
then
  sqlpath=/data/data/com.termux/files/usr/lib
elif [ -f /system/bin/sqlite3 ]
then
  sqlpath=/system/bin
fi

# Check where chattr is
if [ -f /data/data/com.termux/files/usr/bin/applets/chattr ]
then
chattrpath=/data/data/com.termux/files/usr/bin/applets
else
chattrpath=/system/bin
fi

# On to the main show the SQL commands and database permissions
/system/bin/am force-stop /data/data/com.google.android.apps.walletnfcrel
$chattrpath/chattr -i /data/data/com.google.android.gms/databases/dg.db
/system/bin/chmod 777 /data/data/com.google.android.gms/databases/dg.db
$sqlpath/sqlite3 /data/data/com.google.android.gms/databases/dg.db "update main set c='0' where a like '%attest%';"
/system/bin/chmod 440 /data/data/com.google.android.gms/databases/dg.db
$chattrpath/chattr +i /data/data/com.google.android.gms/databases/dg.db

exit

