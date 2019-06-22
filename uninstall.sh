#!/system/bin/sh
# Check where chattr is
if [ -f /data/data/com.termux/files/usr/bin/applets/chattr ]
then
chattrpath=/data/data/com.termux/files/usr/bin/applets
else
chattrpath=/system/xbin
fi

# On to the main show the SQL commands and/or database permissions

# Stop GPay
/system/bin/am force-stop /data/data/com.google.android.apps.walletnfcrel
# Unblock changing file attributes
$chattrpath/chattr -i /data/data/com.google.android.gms/databases/dg.db
# Reset database permissions to default
/system/bin/chmod 660 /data/data/com.google.android.gms/databases/dg.db
# Remove /data/adb/service.d/gpay.sh
/system/bin/rm -rf /data/adb/service.d/gpay.sh

