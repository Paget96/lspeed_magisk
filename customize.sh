#!/system/bin/sh
# Function to install a manager app
installApk() {
	
	filelist=$(ls $1)

	for file in $filelist; do

		extension="${file##*.}"

		if [ "$extension" = "apk" ]; then
			echo "- Installing ""$file""..."
			pm install -r "$1/$file"
			
			ui_print "- Successfully installed $file"
		else
			ui_print "- Error: ""$file" "is not an apk file."
		fi
	done

}

#
# Installing manager and extracting busybox
#
performInstall() {
	# Perform manager installation
	unzip -o "$ZIPFILE" 'app/*' -d /data/local/tmp >&2	

	apkDir="/data/local/tmp/app"
	installApk $apkDir
	
	# Remove app dir from $MODPATH and tmp dir
	rm -rf $apkDir
	rm -rf $MODPATH/app
}

setPermissions() {
  # The following is the default rule, DO NOT remove
  set_perm $MODPATH/system/etc/lspeed/binary/busybox 0 0 0777
  set_perm $MODPATH/system/etc/lspeed/binary/main_function 0 0 0777
  set_perm $MODPATH/system/etc/lspeed/binary/governor_tuner 0 0 0777

  # Here are some examples:
  # set_perm_recursive  $MODPATH/system/lib       0     0       0755      0644
  # set_perm  $MODPATH/system/bin/app_process32   0     2000    0755      u:object_r:zygote_exec:s0
  # set_perm  $MODPATH/system/bin/dex2oat         0     2000    0755      u:object_r:dex2oat_exec:s0
  # set_perm  $MODPATH/system/lib/libart.so       0     0       0644
}

performInstall
setPermissions
