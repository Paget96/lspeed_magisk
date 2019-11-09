#!/system/bin/sh
# L Speed tweak
# Codename : lspeed
version="v1.0-alpha1";
date=09-11-2019;
# Developer : Paget96
# Paypal : https://paypal.me/Paget96

# Variables
date="[$(date +"%H:%M:%S %d-%m-%Y")]";


#PATHS
LSPEED=/data/lspeed
LOG_DIR=$LSPEED/logs
LOG=$LOG_DIR/main_log.log
SETUP_DIR=$LSPEED/setup
PROFILE=$SETUP_DIR/profile
USER_PROFILE=$SETUP_DIR/user_profile

# Detecting modules path
if [ -d /data/adb/modules ]; then
	MODULES=/data/adb/modules
elif [ -d /sbin/.core/img ]; then
	MODULES=/sbin/.core/img
elif [ -d /sbin/.magisk/img ]; then
	MODULES=/sbin/.magisk/img
fi;

# Functions
createFile() {
    touch "$1"
	chmod 0644 "$1"
}

sendToLog() {
    echo "$1" | tee -a $LOG;
}
	
write() {
	chmod 0644 "$1"
    echo -n "$2" > "$1"
}

lockFile() {
	chmod 0644 "$1"
    echo -n "$2" > "$1"
	chmod 044 "$1"
}
R
# Setting up default L Speed dirs and paths
# If for any reason any of them are missing, add them manually
if [ ! -d $LSPEED ]; then
	mkdir -p $LSPEED
fi;

if [ ! -d $LOG_DIR ]; then
	mkdir -p $LOG_DIR
fi;

if [ -d $LOG_DIR ]; then
	createFile $LOG
fi;

if [ ! -d $SETUP_DIR ]; then
	mkdir -p $SETUP_DIR
fi;

if [ -d $SETUP_DIR ]; then
	createFile $PROFILE
	write $PROFILE "0"
	createFile $USER_PROFILE
	write $USER_PROFILE "0"
fi;

# Remove old logs when running the script again
if [ -d $LOG_DIR ]; then
	rm $LOG_DIR
fi;

# Tweaks
batteryImprovements() {
sendToLog "$date Activating battery improvements...";

# Disabling ksm
if [ -e "/sys/kernel/mm/ksm/run" ]; then
chmod 0644 /sys/kernel/mm/ksm/run
write /sys/kernel/mm/ksm/run "0";
sendToLog "$date KSM is disabled, saving battery cycles and improving battery life...";
fi;

# Disabling uksm
if [ -e "/sys/kernel/mm/uksm/run" ]; then
chmod 0644 /sys/kernel/mm/uksm/run
write /sys/kernel/mm/uksm/run "0"
sendToLog "$date UKSM is disabled, saving battery cycles and improving battery life...";
fi;

# Kernel sleepers
if [ -e "/sys/kernel/sched/gentle_fair_sleepers" ]; then
write /sys/kernel/sched/gentle_fair_sleepers "0"
sendToLog "$date Gentle fair sleepers disabled...";
fi;

if [ -e "/sys/kernel/sched/arch_power" ]; then
write /sys/kernel/sched/arch_power "1"
sendToLog "$date Arch power enabled...";
fi;

if [ -e "/sys/kernel/debug/sched_features" ]; then

# Only give sleepers 50% of their service deficit. This allows
# them to run sooner, but does not allow tons of sleepers to
# rip the spread apart.
write /sys/kernel/debug/sched_features "NO_GENTLE_FAIR_SLEEPERS"
sendToLog "$date GENTLE_FAIR_SLEEPERS disabled...";

write /sys/kernel/debug/sched_features "ARCH_POWER"
sendToLog "$date ARCH_POWER enabled...";
fi;

# Enable fast charging
if [ -e "/sys/kernel/fast_charge/force_fast_charge" ];  then
chmod 0644 /sys/kernel/fast_charge/force_fast_charge
write /sys/kernel/fast_charge/force_fast_charge "1"
sendToLog "$date Fast charge enabled";
fi;

setprop ro.audio.flinger_standbytime_ms 300
sendToLog "$date Set low audio flinger standby delay to 300ms for reducing power consumption";

for i in /sys/class/scsi_disk/*; do
write /sys/class/scsi_disk/"$i"/cache_type "temporary none"
sendToLog "$date Set cache type to temporary none in $i";
done
 
if [ -e /sys/module/wakeup/parameters/enable_bluetooth_timer ]; then
write /sys/module/wakeup/parameters/enable_bluetooth_timer "Y"
write /sys/module/wakeup/parameters/enable_ipa_ws "N"
write /sys/module/wakeup/parameters/enable_netlink_ws "Y"
write /sys/module/wakeup/parameters/enable_netmgr_wl_ws "Y"
write /sys/module/wakeup/parameters/enable_qcom_rx_wakelock_ws "N"
write /sys/module/wakeup/parameters/enable_timerfd_ws "Y"
write /sys/module/wakeup/parameters/enable_wlan_extscan_wl_ws "N"
write /sys/module/wakeup/parameters/enable_wlan_wow_wl_ws "N"
write /sys/module/wakeup/parameters/enable_wlan_ws "N"
write /sys/module/wakeup/parameters/enable_netmgr_wl_ws "N"
write /sys/module/wakeup/parameters/enable_wlan_wow_wl_ws "N"
write /sys/module/wakeup/parameters/enable_wlan_ipa_ws "N"
write /sys/module/wakeup/parameters/enable_wlan_pno_wl_ws "N"
write > /sys/module/wakeup/parameters/enable_wcnss_filter_lock_ws "N"
sendToLog "$date Blocked various wakelocks";
fi;

if [ -e /sys/module/bcmdhd/parameters/wlrx_divide ]; then
write /sys/module/bcmdhd/parameters/wlrx_divide "4"
write /sys/module/bcmdhd/parameters/wlctrl_divide "4"
sendToLog "$date wlan wakelocks blocked";
fi;

if [ -e /sys/devices/virtual/misc/boeffla_wakelock_blocker/wakelock_blocker ]; then
write /sys/devices/virtual/misc/boeffla_wakelock_blocker/wakelock_blocker "wlan_pno_wl;wlan_ipa;wcnss_filter_lock;[timerfd];hal_bluetooth_lock;IPA_WS;sensor_ind;wlan;netmgr_wl;qcom_rx_wakelock;wlan_wow_wl;wlan_extscan_wl;NETLINK;bam_dmux_wakelock;IPA_RM12"
sendToLog "$date updated Boeffla wakelock blocker";

elif [ -e /sys/class/misc/boeffla_wakelock_blocker/wakelock_blocker ]; then
write /sys/class/misc/boeffla_wakelock_blocker/wakelock_blocker "wlan_pno_wl;wlan_ipa;wcnss_filter_lock;[timerfd];hal_bluetooth_lock;IPA_WS;sensor_ind;wlan;netmgr_wl;qcom_rx_wakelock;wlan_wow_wl;wlan_extscan_wl;NETLINK;bam_dmux_wakelock;IPA_RM12"
sendToLog "$date updated Boeffla wakelock blocker";
fi;

# lpm Levels
lpm=/sys/module/lpm_levels
if [ -d $lpm/parameters ]; then
write $lpm/enable_low_power/l2 "4"
write $lpm/parameters/lpm_prediction "Y"
write $lpm/parameters/menu_select "N"
write $lpm/parameters/print_parsed_dt "N"
write $lpm/parameters/sleep_disabled "N"
write $lpm/parameters/sleep_time_override "0"
sendToLog "$date Low power mode sleep enabled";
fi;

if [ -e "/sys/class/lcd/panel/power_reduce" ]; then
chmod 0644 /sys/class/lcd/panel/power_reduce
write /sys/class/lcd/panel/power_reduce "1"
sendToLog "$date LCD power reduce enabled";
fi;

if [ -e "/sys/module/pm2/parameters/idle_sleep_mode" ]; then
chmod 0644 /sys/module/pm2/parameters/idle_sleep_mode
write /sys/module/pm2/parameters/idle_sleep_mode "Y"
sendToLog "$date PM2 module idle sleep mode enabled";
fi;

sendToLog "$date Battery improvements are enabled";
}


sendToLog "$date Starting L Speed";

# Default preset
#userProfile=$(cat $USER_PROFILE);
#if [ -e $USER_PROFILE ] && [ "$userProfile" != "0" ]; then
	# set up user defined profile
	#currentProfile=$(cat $PROFILE);
	#sendToLog "$date Setting up user profile";
#else 

currentProfile=$(cat $PROFILE);
if [ "$currentProfile" -eq 0 ]  || [ ! -e $PROFILE ]; then
# use default
sendToLog "$date Applying default profile";
batteryImprovements;
		
elif [ "$currentProfile" -eq 1 ]; then
#use power saving
sendToLog "$date Applying power saving profile";
batteryImprovements;

elif [ "$currentProfile" -eq 2 ]; then
# use balanced
sendToLog "$date Applying balanced profile";
batteryImprovements;

elif [ "$currentProfile" -eq 3 ]; then
# use performance
sendToLog "$date Applying performance profile";
batteryImprovements;
		
fi;

exit 0
