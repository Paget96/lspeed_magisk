#!/system/bin/sh
# L Speed tweak
# Codename : lspeed
version="v1.0-beta5";
date=15-11-2019;
# Developer : Paget96
# Paypal : https://paypal.me/Paget96

# To select current profile go to /data/lspeed/setup
# and edit file "profile"
# 0 - default
# 1 - power saving
# 2 - balanced
# 3 - performance
# Save the file and reboot phone
#
# To check if mod working go to /data/lspeed/logs/main_log.log
# that's main output after executing service.sh
#
#
#

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
	chmod 0644 "$1" 2> /dev/null
}

sendToLog() {
    echo "$1" | tee -a $LOG
}
	
write() {
	chmod 0644 "$1" 2> /dev/null
    echo -n "$2" > "$1" 2> /dev/null
}

lockFile() {
	chmod 0644 "$1" 2> /dev/null
    echo -n "$2" > "$1" 2> /dev/null
	chmod 044 "$1" 2> /dev/null
}

# Setting up default L Speed dirs and files
# If for any reason any of them are missing, add them manually
if [ ! -d $LSPEED ]; then
	mkdir -p $LSPEED
fi;

# Remove old logs when running the script again
# and create dir if not exists
if [ -d $LOG_DIR ]; then
	rm -rf $LOG_DIR
	mkdir -p $LOG_DIR
else
	mkdir -p $LOG_DIR
fi;

# Create setup dir and child files and dirs
# Needed for module working at all
# /data/lsepeed/setup/profile
# /data/lsepeed/setup/user_profile/*
if [ ! -d $SETUP_DIR ]; then
	mkdir -p $SETUP_DIR
fi;

if [ -f $PROFILE ]; then
	createFile $PROFILE
fi;

# Remove user_profile if it's already mounted as a file
# This is needed to prevent crashes while running the script
if [ -f $USER_PROFILE ]; then
	rm -rf $USER_PROFILE
fi;

# Directory dedicated for storing current profile
if [ ! -d $USER_PROFILE ]; then
	mkdir -p $USER_PROFILE
fi;

if [ -d $USER_PROFILE ]; then
	createFile $USER_PROFILE/battery_improvements
	
	# CPU section
	createFile $USER_PROFILE/cpu_optimization
	createFile $USER_PROFILE/gov_tuner
	
	createFile $USER_PROFILE/entropy
	
	# GPU section
	createFile $USER_PROFILE/gpu_optimizer
	createFile $USER_PROFILE/optimize_buffers
	createFile $USER_PROFILE/render_opengles_using_gpu
	createFile $USER_PROFILE/use_opengl_skia

	# I/O tweaks section
	createFile $USER_PROFILE/disable_io_stats
	createFile $USER_PROFILE/io_blocks_optimization
	createFile $USER_PROFILE/io_extended_queue
	createFile $USER_PROFILE/partition_remount
	createFile $USER_PROFILE/scheduler_tuner
	createFile $USER_PROFILE/sd_tweak

	# LNET tweaks section
	createFile $USER_PROFILE/dns
	createFile $USER_PROFILE/net_buffers
	createFile $USER_PROFILE/net_speed_plus
	createFile $USER_PROFILE/net_tcp
	createFile $USER_PROFILE/optimize_ril
	
	# Other
	createFile $USER_PROFILE/disable_debugging
	createFile $USER_PROFILE/disable_kernel_panic
	
	# RAM manager section
	createFile $USER_PROFILE/ram_manager
	createFile $USER_PROFILE/disable_multitasking_limitations
	createFile $USER_PROFILE/low_ram_flag
	createFile $USER_PROFILE/oom_killer
	createFile $USER_PROFILE/swappiness
	createFile $USER_PROFILE/virtual_memory
	createFile $USER_PROFILE/heap_optimization
	createFile $USER_PROFILE/zram_optimization

fi;

#
# Battery improvements
#
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

for i in $(ls -d /sys/class/scsi_disk/*); do
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

#
# CPU Optimization battery profile
#
cpuOptimizationBattery() {
real_cpu_cores=$(ls /sys/devices/system/cpu | grep -c ^cpu[0-9]);
cpu_cores=$((real_cpu_cores-1));

echo "$date Optimizing CPU..." >> $LOG;

if [ -e "/sys/devices/system/cpu/cpuidle/use_deepest_state" ]; then
chmod 0644 /sys/devices/system/cpu/cpuidle/use_deepest_state
echo "1" > /sys/devices/system/cpu/cpuidle/use_deepest_state
echo "$date Enable deepest CPU idle state" >> $LOG;
fi;

# Disable krait voltage boost
if [ -e "/sys/module/acpuclock_krait/parameters/boost" ];  then
chmod 0644 /sys/module/acpuclock_krait/parameters/boost
echo "N" > /sys/module/acpuclock_krait/parameters/boost
echo "$date Disable Krait voltage boost" >> $LOG;
fi;

if [ -e "/sys/module/workqueue/parameters/power_efficient" ]; then
chmod 0644 /sys/module/workqueue/parameters/power_efficient
echo "Y" > /sys/module/workqueue/parameters/power_efficient
echo "$date Power-save workqueues enabled" >> $LOG;
fi;

if [ -e /dev/cpuset ]; then
echo "$date Detected $real_cpu_cores CPU cores" >> $LOG;
echo "$date Optimizing CPUSET for $real_cpu_cores CPU cores" >> $LOG;
if [ "$cpu_cores" -eq 3 ]; then
	echo "1" > /dev/cpuset/background/cpus
	echo "0-1" > /dev/cpuset/system-background/cpus
	echo "0-3" > /dev/cpuset/foreground/cpus
	echo "0-3" > /dev/cpuset/top-app/cpus
elif [ "$cpu_cores" -eq 7 ]; then
	echo "2-3" > /dev/cpuset/background/cpus
	echo "0-3" > /dev/cpuset/system-background/cpus
	echo "0-7" > /dev/cpuset/foreground/cpus
	echo "0-7" > /dev/cpuset/top-app/cpus
elif [ "$cpu_cores" -eq 9 ]; then
	echo "2-3" > /dev/cpuset/background/cpus
	echo "0-3" > /dev/cpuset/system-background/cpus
	echo "0-8" > /dev/cpuset/foreground/cpus
	echo "0-8" > /dev/cpuset/top-app/cpus
fi;
echo "$date CPUSET optimized" >> $LOG;
fi;

if [ -e "/sys/module/workqueue/parameters/power_efficient" ]; then
chmod 0644 /sys/module/workqueue/parameters/power_efficient
echo "Y" > /sys/module/workqueue/parameters/power_efficient
echo "$date Power-save workqueues enabled, scheduling workqueues on awake CPUs to save power." >> $LOG;
fi;

# EAS related tweaks
echo "0" > /dev/stune/schedtune.prefer_idle
echo "0" > /dev/stune/background/schedtune.prefer_idle
echo "0" > /dev/stune/foreground/schedtune.prefer_idle
echo "1" > /dev/stune/top-app/schedtune.prefer_idle

if [ -e /proc/sys/kernel/sched_is_big_little ]; then
    echo "1" > /proc/sys/kernel/sched_is_big_little
fi;
if [ -e /proc/sys/kernel/sched_boost ]; then
    echo "0" > /proc/sys/kernel/sched_boost
fi;

echo "64" > /proc/sys/kernel/sched_nr_migrate
echo "1" > /proc/sys/kernel/sched_cstate_aware
echo "0" > /proc/sys/kernel/sched_child_runs_first
echo "0" > /proc/sys/kernel/sched_initial_task_util
echo "0" > /proc/sys/kernel/sched_use_walt_task_util
echo "0" > /proc/sys/kernel/sched_use_walt_cpu_util
echo "0" > /proc/sys/kernel/sched_walt_init_task_load_pct

if [ -e /sys/module/cpu_input_boost/parameters/input_boost_duration ]; then
chmod 0644 /sys/module/cpu_input_boost/parameters/input_boost_duration
echo "0" > /sys/module/cpu_input_boost/parameters/input_boost_duration
echo "$date CPU Boost Input Duration=0" >> $LOG;
fi;

if [ -e /sys/module/cpu_boost/parameters/input_boost_ms ]; then
chmod 0644 /sys/module/cpu_boost/parameters/input_boost_ms
echo "0" > /sys/module/cpu_boost/parameters/input_boost_ms
echo "$date CPU Boost Input Ms=0" >> $LOG;
fi;

if [ -e /sys/module/cpu_boost/parameters/input_boost_ms_s2 ]; then
chmod 0644 /sys/module/cpu_boost/parameters/input_boost_ms_s2
echo "0" > /sys/module/cpu_boost/parameters/input_boost_ms_s2
echo "$date CPU Boost Input Ms_S2=0" >> $LOG;
fi;

if [ -e /sys/module/cpu_boost/parameters/dynamic_stune_boost ]; then
chmod 0644 /sys/module/cpu_boost/parameters/dynamic_stune_boost
echo "0" > /sys/module/cpu_boost/parameters/dynamic_stune_boost
echo "$date CPU Boost Dyn_Stune_Boost=0" >> $LOG;
fi;

if [ -e /sys/module/cpu_input_boost/parameters/dynamic_stune_boost ]; then
chmod 0644 /sys/module/cpu_input_boost/parameters/dynamic_stune_boost
echo "0" > /sys/module/cpu_input_boost/parameters/dynamic_stune_boost
echo "$date CPU Boost Dyn_Stune_Boost=0" >> $LOG;
fi;

if [ -e /sys/module/cpu_input_boost/parameters/general_stune_boost ]; then
chmod 0644 /sys/module/cpu_input_boost/parameters/general_stune_boost
echo "10" > /sys/module/cpu_input_boost/parameters/general_stune_boost
echo "$date CPU Boost General_Stune_Boost=10" >> $LOG;
fi;

if [ -e /sys/module/dsboost/parameters/input_boost_duration ]; then
chmod 0644 /sys/module/dsboost/parameters/input_boost_duration
echo "0" > /sys/module/dsboost/parameters/input_boost_duration
echo "$date Dsboost Input Boost Duration=0" >> $LOG;
fi;

if [ -e /sys/module/dsboost/parameters/input_stune_boost ]; then
chmod 0644 /sys/module/dsboost/parameters/input_stune_boost
echo "0" > /sys/module/dsboost/parameters/input_stune_boost
echo "$date Dsboost Input Stune Boost Duration=0" >> $LOG;
fi;

if [ -e /sys/module/dsboost/parameters/sched_stune_boost ]; then
chmod 0644 /sys/module/dsboost/parameters/sched_stune_boost
echo "0" > /sys/module/dsboost/parameters/sched_stune_boost
echo "$date Dsboost Sched_Stune_Boost=0" >> $LOG;
fi;

if [ -e /sys/module/dsboost/parameters/cooldown_boost_duration ]; then
chmod 0644 /sys/module/dsboost/parameters/cooldown_boost_duration
echo "0" > /sys/module/dsboost/parameters/cooldown_boost_duration
echo "$date Dsboost Cooldown_Boost_Duration=0" >> $LOG;
fi;

if [ -e /sys/module/dsboost/parameters/cooldown_stune_boost ]; then
chmod 0644 /sys/module/dsboost/parameters/cooldown_stune_boost
echo "0" > /sys/module/dsboost/parameters/cooldown_stune_boost
echo "$date Dsboost Cooldown_Stune_Boost=0" >> $LOG;
fi;

# CPU CTL
for i in $(find /dev/cpuctl -name cpu.rt_period_us); do
 echo "1000000" > "$i"
 echo "$date 1000000 to $i" >> $LOG;
done

for i in $(find /dev/cpuctl -name cpu.rt_runtime_us); do
 echo "950000" > "$i"
 echo "$date 950000 to $i" >> $LOG;
done

sched_rt_period_us=/proc/sys/kernel/sched_rt_period_us
if [ -e $sched_rt_period_us ]; then
 echo "1000000" > $sched_rt_period_us
 echo "$date sched_rt_period_us=1000000" >> $LOG;
fi;

sched_rt_runtime_us=/proc/sys/kernel/sched_rt_runtime_us
if [ -e $sched_rt_runtime_us ]; then
 echo "950000" > $sched_rt_runtime_us
 echo "$date sched_rt_runtime_us=950000" >> $LOG;
fi;

sched_wake_to_idle=/proc/sys/kernel/sched_wake_to_idle
if [ -e $sched_wake_to_idle ]; then
 echo "0" > $sched_wake_to_idle
 echo "$date sched_wake_to_idle=0" >> $LOG;
fi;

# Disable touch boost
touchboost=/sys/module/msm_performance/parameters/touchboost
if [ -e $touchboost ]; then
 echo "0" > $touchboost
 echo "$date $touchboost=0" >> $LOG;
fi;

touch_boost=/sys/power/pnpmgr/touch_boost
if [ -e $touch_boost ]; then
 echo "N" > $touch_boost
 echo "$date $touch_boost=N" >> $LOG;
fi;

#Disable CPU Boost
boost_ms=/sys/module/cpu_boost/parameters/boost_ms
if [ -e $boost_ms ]; then
 echo "0" > $boost_ms
 echo "$date $boost_ms=0" >> $LOG;
fi;

sched_boost_on_input=/sys/module/cpu_boost/parameters/sched_boost_on_input
if [ -e $sched_boost_on_input ]; then
 echo "N" > $sched_boost_on_input
 echo "$date $sched_boost_on_input=0" >> $LOG;
fi;

echo "$date CPU is optimized..." >> $LOG;

}

#
# CPU Optimization balanced profile
#
cpuOptimizationBalanced() {
real_cpu_cores=$(ls /sys/devices/system/cpu | grep -c ^cpu[0-9]);
cpu_cores=$((real_cpu_cores-1));

echo "$date Optimizing CPU..." >> $LOG;

if [ -e "/sys/devices/system/cpu/cpuidle/use_deepest_state" ]; then
chmod 0644 /sys/devices/system/cpu/cpuidle/use_deepest_state
echo "1" > /sys/devices/system/cpu/cpuidle/use_deepest_state
echo "$date Enable deepest CPU idle state" >> $LOG;
fi;

# Disable krait voltage boost
if [ -e "/sys/module/acpuclock_krait/parameters/boost" ];  then
chmod 0644 /sys/module/acpuclock_krait/parameters/boost
echo "N" > /sys/module/acpuclock_krait/parameters/boost
echo "$date Disable Krait voltage boost" >> $LOG;
fi;

if [ -e "/sys/module/workqueue/parameters/power_efficient" ]; then
chmod 0644 /sys/module/workqueue/parameters/power_efficient
echo "Y" > /sys/module/workqueue/parameters/power_efficient
echo "$date Power-save workqueues enabled" >> $LOG;
fi;

if [ -e /dev/cpuset ]; then
echo "$date Detected $real_cpu_cores CPU cores" >> $LOG;
echo "$date Optimizing CPUSET for $real_cpu_cores CPU cores" >> $LOG;
if [ "$cpu_cores" -eq 3 ]; then
	echo "1" > /dev/cpuset/background/cpus
	echo "0-1" > /dev/cpuset/system-background/cpus
	echo "0-3" > /dev/cpuset/foreground/cpus
	echo "0-3" > /dev/cpuset/top-app/cpus
elif [ "$cpu_cores" -eq 7 ]; then
	echo "2-3" > /dev/cpuset/background/cpus
	echo "0-3" > /dev/cpuset/system-background/cpus
	echo "0-7" > /dev/cpuset/foreground/cpus
	echo "0-7" > /dev/cpuset/top-app/cpus
elif [ "$cpu_cores" -eq 9 ]; then
	echo "2-3" > /dev/cpuset/background/cpus
	echo "0-3" > /dev/cpuset/system-background/cpus
	echo "0-8" > /dev/cpuset/foreground/cpus
	echo "0-8" > /dev/cpuset/top-app/cpus
fi;
echo "$date CPUSET optimized" >> $LOG;
fi;

if [ -e "/sys/module/workqueue/parameters/power_efficient" ]; then
chmod 0644 /sys/module/workqueue/parameters/power_efficient
echo "N" > /sys/module/workqueue/parameters/power_efficient
echo "$date Power-save workqueues disabled, scheduling workqueues on awake CPUs to save power disabled" >> $LOG;
fi;

# EAS related tweaks
echo "0" > /dev/stune/schedtune.prefer_idle
echo "0" > /dev/stune/background/schedtune.prefer_idle
echo "1" > /dev/stune/foreground/schedtune.prefer_idle
echo "1" > /dev/stune/top-app/schedtune.prefer_idle

echo "1" > /proc/sys/kernel/sched_cstate_aware
if [ -e /proc/sys/kernel/sched_is_big_little ]; then
    echo "1" > /proc/sys/kernel/sched_is_big_little
fi;
if [ -e /proc/sys/kernel/sched_boost ]; then
    echo "0" > /proc/sys/kernel/sched_boost
fi;

echo "96" > /proc/sys/kernel/sched_nr_migrate
echo "1" > /proc/sys/kernel/sched_cstate_aware
echo "0" > /proc/sys/kernel/sched_child_runs_first
echo "0" > /proc/sys/kernel/sched_initial_task_util
echo "1" > /proc/sys/kernel/sched_use_walt_task_util
echo "1" > /proc/sys/kernel/sched_use_walt_cpu_util
echo "0" > /proc/sys/kernel/sched_walt_init_task_load_pct

if [ -e /sys/module/cpu_input_boost/parameters/input_boost_duration ]; then
chmod 0644 /sys/module/cpu_input_boost/parameters/input_boost_duration
echo "60" > /sys/module/cpu_input_boost/parameters/input_boost_duration
echo "$date CPU Boost Input Duration=60" >> $LOG;
fi;

if [ -e /sys/module/cpu_boost/parameters/input_boost_ms ]; then
chmod 0644 /sys/module/cpu_boost/parameters/input_boost_ms
echo "60" > /sys/module/cpu_boost/parameters/input_boost_ms
echo "$date CPU Boost Input Ms=60" >> $LOG;
fi;

if [ -e /sys/module/cpu_boost/parameters/input_boost_ms_s2 ]; then
chmod 0644 /sys/module/cpu_boost/parameters/input_boost_ms_s2
echo "30" > /sys/module/cpu_boost/parameters/input_boost_ms_s2
echo "$date CPU Boost Input Ms_S2=30" >> $LOG;
fi;

if [ -e /sys/module/cpu_boost/parameters/dynamic_stune_boost ]; then
chmod 0644 /sys/module/cpu_boost/parameters/dynamic_stune_boost
echo "20" > /sys/module/cpu_boost/parameters/dynamic_stune_boost
echo "$date CPU Boost Dyn_Stune_Boost=20" >> $LOG;
fi;

if [ -e /sys/module/cpu_input_boost/parameters/dynamic_stune_boost ]; then
chmod 0644 /sys/module/cpu_input_boost/parameters/dynamic_stune_boost
echo "20" > /sys/module/cpu_input_boost/parameters/dynamic_stune_boost
echo "$date CPU Boost Dyn_Stune_Boost=20" >> $LOG;
fi;

if [ -e /sys/module/cpu_input_boost/parameters/general_stune_boost ]; then
chmod 0644 /sys/module/cpu_input_boost/parameters/general_stune_boost
echo "60" > /sys/module/cpu_input_boost/parameters/general_stune_boost
echo "$date CPU Boost General_Stune_Boost=60" >> $LOG;
fi;

if [ -e /sys/module/dsboost/parameters/input_boost_duration ]; then
chmod 0644 /sys/module/dsboost/parameters/input_boost_duration
echo "60" > /sys/module/dsboost/parameters/input_boost_duration
echo "$date Dsboost Input Boost Duration=60" >> $LOG;
fi;

if [ -e /sys/module/dsboost/parameters/input_stune_boost ]; then
chmod 0644 /sys/module/dsboost/parameters/input_stune_boost
echo "60" > /sys/module/dsboost/parameters/input_stune_boost
echo "$date Dsboost Input Stune Boost Duration=60" >> $LOG;
fi;

if [ -e /sys/module/dsboost/parameters/sched_stune_boost ]; then
chmod 0644 /sys/module/dsboost/parameters/sched_stune_boost
echo "10" > /sys/module/dsboost/parameters/sched_stune_boost
echo "$date Dsboost Sched_Stune_Boost=10" >> $LOG;
fi;

if [ -e /sys/module/dsboost/parameters/cooldown_boost_duration ]; then
chmod 0644 /sys/module/dsboost/parameters/cooldown_boost_duration
echo "60" > /sys/module/dsboost/parameters/cooldown_boost_duration
echo "$date Dsboost Cooldown_Boost_Duration=60" >> $LOG;
fi;

if [ -e /sys/module/dsboost/parameters/cooldown_stune_boost ]; then
chmod 0644 /sys/module/dsboost/parameters/cooldown_stune_boost
echo "10" > /sys/module/dsboost/parameters/cooldown_stune_boost
echo "$date Dsboost Cooldown_Stune_Boost=10" >> $LOG;
fi;

for i in $(find /dev/cpuctl -name cpu.rt_period_us); do
 echo "1000000" > "$i"
 echo "$date 1000000 to $i" >> $LOG;
done

for i in $(find /dev/cpuctl -name cpu.rt_runtime_us); do
 echo "950000" > "$i"
 echo "$date 950000 to $i" >> $LOG;
done

sched_rt_period_us=/proc/sys/kernel/sched_rt_period_us
if [ -e $sched_rt_period_us ]; then
 echo "1000000" > $sched_rt_period_us
 echo "$date sched_rt_period_us=1000000" >> $LOG;
fi;

sched_rt_runtime_us=/proc/sys/kernel/sched_rt_runtime_us
if [ -e $sched_rt_runtime_us ]; then
 echo "950000" > $sched_rt_runtime_us
 echo "$date sched_rt_runtime_us=950000" >> $LOG;
fi;

sched_wake_to_idle=/proc/sys/kernel/sched_wake_to_idle
if [ -e $sched_wake_to_idle ]; then
 echo "0" > $sched_wake_to_idle
 echo "$date sched_wake_to_idle=0" >> $LOG;
fi;

# Disable touch boost
touchboost=/sys/module/msm_performance/parameters/touchboost
if [ -e $touchboost ]; then
 echo "0" > $touchboost
 echo "$date $touchboost=0" >> $LOG;
fi;

touch_boost=/sys/power/pnpmgr/touch_boost
if [ -e $touch_boost ]; then
 echo "N" > $touch_boost
 echo "$date $touch_boost=N" >> $LOG;
fi;

#Disable CPU Boost
boost_ms=/sys/module/cpu_boost/parameters/boost_ms
if [ -e $boost_ms ]; then
 echo "0" > $boost_ms
 echo "$date $boost_ms=0" >> $LOG;
fi;

sched_boost_on_input=/sys/module/cpu_boost/parameters/sched_boost_on_input
if [ -e $sched_boost_on_input ]; then
 echo "N" > $sched_boost_on_input
 echo "$date $sched_boost_on_input=0" >> $LOG;
fi;

echo "$date CPU is optimized..." >> $LOG;

}

#
# CPU Optimization performance profile
#
cpuOptimizationPerformance() {
real_cpu_cores=$(ls /sys/devices/system/cpu | grep -c ^cpu[0-9]);
cpu_cores=$((real_cpu_cores-1));

echo "$date Optimizing CPU..." >> $LOG;

if [ -e "/sys/devices/system/cpu/cpuidle/use_deepest_state" ]; then
chmod 0644 /sys/devices/system/cpu/cpuidle/use_deepest_state
echo "1" > /sys/devices/system/cpu/cpuidle/use_deepest_state
echo "$date Enable deepest CPU idle state" >> $LOG;
fi;

# Disable krait voltage boost
if [ -e "/sys/module/acpuclock_krait/parameters/boost" ];  then
chmod 0644 /sys/module/acpuclock_krait/parameters/boost
echo "Y" > /sys/module/acpuclock_krait/parameters/boost
echo "$date Enable Krait voltage boost" >> $LOG;
fi;

if [ -e "/sys/module/workqueue/parameters/power_efficient" ]; then
chmod 0644 /sys/module/workqueue/parameters/power_efficient
echo "N" > /sys/module/workqueue/parameters/power_efficient
echo "$date Power-save workqueues disabled" >> $LOG;
fi;

if [ -e /dev/cpuset ]; then
echo "$date Detected $real_cpu_cores CPU cores" >> $LOG;
echo "$date Optimizing CPUSET for $real_cpu_cores CPU cores" >> $LOG;
if [ "$cpu_cores" -eq 3 ]; then
	echo "1" > /dev/cpuset/background/cpus
	echo "0-1" > /dev/cpuset/system-background/cpus
	echo "0-3" > /dev/cpuset/foreground/cpus
	echo "0-3" > /dev/cpuset/top-app/cpus
elif [ "$cpu_cores" -eq 7 ]; then
	echo "2-3" > /dev/cpuset/background/cpus
	echo "0-3" > /dev/cpuset/system-background/cpus
	echo "0-7" > /dev/cpuset/foreground/cpus
	echo "0-7" > /dev/cpuset/top-app/cpus
elif [ "$cpu_cores" -eq 9 ]; then
	echo "2-3" > /dev/cpuset/background/cpus
	echo "0-3" > /dev/cpuset/system-background/cpus
	echo "0-8" > /dev/cpuset/foreground/cpus
	echo "0-8" > /dev/cpuset/top-app/cpus
fi;
echo "$date CPUSET optimized" >> $LOG;
fi;

if [ -e "/sys/module/workqueue/parameters/power_efficient" ]; then
chmod 0644 /sys/module/workqueue/parameters/power_efficient
echo "N" > /sys/module/workqueue/parameters/power_efficient
echo "$date Power-save workqueues disabled, scheduling workqueues on awake CPUs to save power disabled" >> $LOG;
fi;

# EAS related tweaks
echo "0" > /dev/stune/schedtune.prefer_idle
echo "0" > /dev/stune/background/schedtune.prefer_idle
echo "1" > /dev/stune/foreground/schedtune.prefer_idle
echo "1" > /dev/stune/top-app/schedtune.prefer_idle

echo "1" > /proc/sys/kernel/sched_cstate_aware
if [ -e /proc/sys/kernel/sched_is_big_little ]; then
  echo "1" > /proc/sys/kernel/sched_is_big_little
fi;
if [ -e /proc/sys/kernel/sched_boost ]; then
  echo "0" > /proc/sys/kernel/sched_boost
fi;

if [ -e /proc/sys/kernel/sched_autogroup_enabled ]; then
  echo "0" > /proc/sys/kernel/sched_autogroup_enabled
fi;

echo "128" > /proc/sys/kernel/sched_nr_migrate
echo "1" > /proc/sys/kernel/sched_cstate_aware
echo "0" > /proc/sys/kernel/sched_child_runs_first
echo "10" > /proc/sys/kernel/sched_initial_task_util
echo "1" > /proc/sys/kernel/sched_use_walt_task_util
echo "1" > /proc/sys/kernel/sched_use_walt_cpu_util
echo "10" > /proc/sys/kernel/sched_walt_init_task_load_pct

if [ -e /sys/module/cpu_input_boost/parameters/input_boost_duration ]; then
chmod 0644 /sys/module/cpu_input_boost/parameters/input_boost_duration
echo "120" > /sys/module/cpu_input_boost/parameters/input_boost_duration
echo "$date CPU Boost Input Duration=120" >> $LOG;
fi;

if [ -e /sys/module/cpu_boost/parameters/input_boost_ms ]; then
chmod 0644 /sys/module/cpu_boost/parameters/input_boost_ms
echo "120" > /sys/module/cpu_boost/parameters/input_boost_ms
echo "$date CPU Boost Input Ms=120" >> $LOG;
fi;

if [ -e /sys/module/cpu_boost/parameters/input_boost_ms_s2 ]; then
chmod 0644 /sys/module/cpu_boost/parameters/input_boost_ms_s2
echo "50" > /sys/module/cpu_boost/parameters/input_boost_ms_s2
echo "$date CPU Boost Input Ms_S2=50" >> $LOG;
fi;

if [ -e /sys/module/cpu_boost/parameters/dynamic_stune_boost ]; then
chmod 0644 /sys/module/cpu_boost/parameters/dynamic_stune_boost
echo "30" > /sys/module/cpu_boost/parameters/dynamic_stune_boost
echo "$date CPU Boost Dyn_Stune_Boost=30" >> $LOG;
fi;

if [ -e /sys/module/cpu_input_boost/parameters/dynamic_stune_boost ]; then
chmod 0644 /sys/module/cpu_input_boost/parameters/dynamic_stune_boost
echo "30" > /sys/module/cpu_input_boost/parameters/dynamic_stune_boost
echo "$date CPU Boost Dyn_Stune_Boost=30" >> $LOG;
fi;

if [ -e /sys/module/cpu_input_boost/parameters/general_stune_boost ]; then
chmod 0644 /sys/module/cpu_input_boost/parameters/general_stune_boost
echo "10" > /sys/module/cpu_input_boost/parameters/general_stune_boost
echo "$date CPU Boost General_Stune_Boost=10" >> $LOG;
fi;

if [ -e /sys/module/dsboost/parameters/input_boost_duration ]; then
chmod 0644 /sys/module/dsboost/parameters/input_boost_duration
echo "120" > /sys/module/dsboost/parameters/input_boost_duration
echo "$date Dsboost Input Boost Duration=120" >> $LOG;
fi;

if [ -e /sys/module/dsboost/parameters/input_stune_boost ]; then
chmod 0644 /sys/module/dsboost/parameters/input_stune_boost
echo "120" > /sys/module/dsboost/parameters/input_stune_boost
echo "$date Dsboost Input Stune Boost Duration=120" >> $LOG;
fi;

if [ -e /sys/module/dsboost/parameters/sched_stune_boost ]; then
chmod 0644 /sys/module/dsboost/parameters/sched_stune_boost
echo "10" > /sys/module/dsboost/parameters/sched_stune_boost
echo "$date Dsboost Sched_Stune_Boost=10" >> $LOG;
fi;

if [ -e /sys/module/dsboost/parameters/cooldown_boost_duration ]; then
chmod 0644 /sys/module/dsboost/parameters/cooldown_boost_duration
echo "120" > /sys/module/dsboost/parameters/cooldown_boost_duration
echo "$date Dsboost Cooldown_Boost_Duration=120" >> $LOG;
fi;

if [ -e /sys/module/dsboost/parameters/cooldown_stune_boost ]; then
chmod 0644 /sys/module/dsboost/parameters/cooldown_stune_boost
echo "10" > /sys/module/dsboost/parameters/cooldown_stune_boost
echo "$date Dsboost Cooldown_Stune_Boost=10" >> $LOG;
fi;

for i in $(find /dev/cpuctl -name cpu.rt_period_us); do
 echo "1000000" > "$i"
 echo "$date 1000000 to $i" >> $LOG;
done

for i in $(find /dev/cpuctl -name cpu.rt_runtime_us); do
 echo "950000" > "$i"
 echo "$date 950000 to $i" >> $LOG;
done

sched_rt_period_us=/proc/sys/kernel/sched_rt_period_us
if [ -e $sched_rt_period_us ]; then
 echo "1000000" > $sched_rt_period_us
 echo "$date sched_rt_period_us=1000000" >> $LOG;
fi;

sched_rt_runtime_us=/proc/sys/kernel/sched_rt_runtime_us
if [ -e $sched_rt_runtime_us ]; then
 echo "950000" > $sched_rt_runtime_us
 echo "$date sched_rt_runtime_us=950000" >> $LOG;
fi;

sched_wake_to_idle=/proc/sys/kernel/sched_wake_to_idle
if [ -e $sched_wake_to_idle ]; then
 echo "0" > $sched_wake_to_idle
 echo "$date sched_wake_to_idle=0" >> $LOG;
fi;

# Disable touch boost
touchboost=/sys/module/msm_performance/parameters/touchboost
if [ -e $touchboost ]; then
 echo "0" > $touchboost
 echo "$date $touchboost=0" >> $LOG;
fi;

touch_boost=/sys/power/pnpmgr/touch_boost
if [ -e $touch_boost ]; then
 echo "N" > $touch_boost
 echo "$date $touch_boost=N" >> $LOG;
fi;

#Disable CPU Boost
boost_ms=/sys/module/cpu_boost/parameters/boost_ms
if [ -e $boost_ms ]; then
 echo "0" > $boost_ms
 echo "$date $boost_ms=0" >> $LOG;
fi;

sched_boost_on_input=/sys/module/cpu_boost/parameters/sched_boost_on_input
if [ -e $sched_boost_on_input ]; then
 echo "N" > $sched_boost_on_input
 echo "$date $sched_boost_on_input=0" >> $LOG;
fi;

echo "$date CPU is optimized..." >> $LOG;

}

entropyAggressive() {
echo "$date Activating aggressive entropy profile..." >> $LOG;

sysctl -e -w kernel.random.read_wakeup_threshold=512
sysctl -e -w kernel.random.write_wakeup_threshold=1024
sysctl -e -w kernel.random.urandom_min_reseed_secs=90

echo "$date Aggressive entropy profile activated" >> $LOG;
}

entropyEnlarger() {
echo "$date Activating enlarger entropy profile..." >> $LOG;

sysctl -e -w kernel.random.read_wakeup_threshold=128
sysctl -e -w kernel.random.write_wakeup_threshold=896
sysctl -e -w kernel.random.urandom_min_reseed_secs=90

echo "$date Enlarger entropy profile activated" >> $LOG;
}

entropyLight() {
echo "$date Activating light entropy profile..." >> $LOG;

sysctl -e -w kernel.random.read_wakeup_threshold=64
sysctl -e -w kernel.random.write_wakeup_threshold=128
sysctl -e -w kernel.random.urandom_min_reseed_secs=90

echo "$date Light entropy profile activated" >> $LOG;
}

entropyModerate() {
echo "$date Activating moderate entropy profile..." >> $LOG;

sysctl -e -w kernel.random.read_wakeup_threshold=128
sysctl -e -w kernel.random.write_wakeup_threshold=512
sysctl -e -w kernel.random.urandom_min_reseed_secs=90

echo "$date Moderate entropy profile activated" >> $LOG;
}

gpuOptimizerBalanced() {
echo "$date Optimizing GPU..." >> $LOG;

# GPU related tweaks
if [ -d "/sys/class/kgsl/kgsl-3d0" ]; then
	gpu="/sys/class/kgsl/kgsl-3d0"
elif [ -d "/sys/devices/platform/kgsl-3d0.0/kgsl/kgsl-3d0" ]; then
	gpu="/sys/devices/platform/kgsl-3d0.0/kgsl/kgsl-3d0"
elif [ -d "/sys/devices/soc/*.qcom,kgsl-3d0/kgsl/kgsl-3d0" ]; then
	gpu="/sys/devices/soc/*.qcom,kgsl-3d0/kgsl/kgsl-3d0"
elif [ -d "/sys/devices/soc.0/*.qcom,kgsl-3d0/kgsl/kgsl-3d0" ]; then
	gpu="/sys/devices/soc.0/*.qcom,kgsl-3d0/kgsl/kgsl-3d0"
elif [ -d "/sys/devices/platform/*.gpu/devfreq/*.gpu" ]; then
	gpu="/sys/devices/platform/*.gpu/devfreq/*.gpu"	
elif [ -d "/sys/devices/platform/gpusysfs" ]; then
	gpu="/sys/devices/platform/gpusysfs"
elif [ -d "/sys/devices/*.mali" ]; then
	gpu="/sys/devices/*.mali"
elif [ -d "/sys/devices/*.gpu" ]; then
	gpu="/sys/devices/*.gpu"
elif [ -d "/sys/devices/platform/mali.0" ]; then
	gpu="/sys/devices/platform/mali.0"
elif [ -d "/sys/devices/platform/mali-*.0" ]; then
	gpu="/sys/devices/platform/mali-*.0"
elif [ -d "/sys/module/mali/parameters" ]; then
	gpu="/sys/module/mali/parameters"
elif [ -d "/sys/class/misc/mali0" ]; then
	gpu="/sys/class/misc/mali0"
elif [ -d "/sys/kernel/gpu" ]; then
	gpu="/sys/kernel/gpu"
fi

if [ -e /proc/gpufreq/gpufreq_limited_thermal_ignore ]; then
echo "1" > /proc/gpufreq/gpufreq_limited_thermal_ignore
echo "$date Disabled gpufreq thermal" >> $LOG;
fi;

if [ -e /proc/mali/dvfs_enable ]; then
echo "1" > /proc/mali/dvfs_enable
echo "$date dvfs enabled" >> $LOG;
fi;

if [ -e /sys/module/simple_gpu_algorithm/parameters/simple_gpu_activate ]; then
echo "1" > /sys/module/simple_gpu_algorithm/parameters/simple_gpu_activate
echo "Y" > /sys/module/simple_gpu_algorithm/parameters/simple_gpu_activate
echo "$date Simple GPU algorithm enabled" >> $LOG;
fi;

# Adreno idler
if [ -e /sys/module/adreno_idler/parameters/adreno_idler_active ];  then
echo "Y" > /sys/module/adreno_idler/parameters/adreno_idler_active
echo "6000" > /sys/module/adreno_idler/parameters/adreno_idler_idleworkload
echo "15" > /sys/module/adreno_idler/parameters/adreno_idler_downdifferential
echo "15" > /sys/module/adreno_idler/parameters/adreno_idler_idlewait
echo "$date Disabled adreno idler" >> $LOG;
fi;

if [ -e $gpu/devfreq/adrenoboost ]; then
 echo "1" > $gpu/devfreq/adrenoboost
 echo "$date Adreno boost is set to 1" >> $LOG;
fi;

if [ -e $gpu/throttling ]; then
echo "0" > $gpu/throttling
echo "$date GPU throttling disabled" >> $LOG;
fi;

if [ -e $gpu/max_pwrlevel ]; then
echo "0" > $gpu/max_pwrlevel
echo "$date GPU max power level disabled" >> $LOG;
fi;

if [ -e $gpu/force_no_nap ]; then
echo "1" > $gpu/force_no_nap
echo "$date force_no_nap enabled" >> $LOG;
fi;

if [ -e $gpu/bus_split ]; then
echo "1" > $gpu/bus_split
echo "$date bus_split enabled" >> $LOG;
fi;

if [ -e $gpu/force_bus_on ]; then
echo "0" > $gpu/force_bus_on
echo "$date force_bus_on disabled" >> $LOG;
fi;

if [ -e $gpu/force_clk_on ]; then
echo "0" > $gpu/force_clk_on
echo "$date force_clk_on disabled" >> $LOG;
fi;

if [ -e $gpu/force_rail_on ]; then
echo "0" > $gpu/force_rail_on
echo "$date force_rail_on disabled" >> $LOG;
fi;

echo "$date GPU is optimized..." >> $LOG;
}

gpuOprimizerPerformance() {
echo "$date Optimizing GPU..." >> $LOG;

# GPU related tweaks
if [ -d "/sys/class/kgsl/kgsl-3d0" ]; then
	gpu="/sys/class/kgsl/kgsl-3d0"
elif [ -d "/sys/devices/platform/kgsl-3d0.0/kgsl/kgsl-3d0" ]; then
	gpu="/sys/devices/platform/kgsl-3d0.0/kgsl/kgsl-3d0"
elif [ -d "/sys/devices/soc/*.qcom,kgsl-3d0/kgsl/kgsl-3d0" ]; then
	gpu="/sys/devices/soc/*.qcom,kgsl-3d0/kgsl/kgsl-3d0"
elif [ -d "/sys/devices/soc.0/*.qcom,kgsl-3d0/kgsl/kgsl-3d0" ]; then
	gpu="/sys/devices/soc.0/*.qcom,kgsl-3d0/kgsl/kgsl-3d0"
elif [ -d "/sys/devices/platform/*.gpu/devfreq/*.gpu" ]; then
	gpu="/sys/devices/platform/*.gpu/devfreq/*.gpu"
elif [ -d "/sys/devices/platform/gpusysfs" ]; then
	gpu="/sys/devices/platform/gpusysfs"
elif [ -d "/sys/devices/*.mali" ]; then
	gpu="/sys/devices/*.mali"
elif [ -d "/sys/devices/*.gpu" ]; then
	gpu="/sys/devices/*.gpu"
elif [ -d "/sys/devices/platform/mali.0" ]; then
	gpu="/sys/devices/platform/mali.0"
elif [ -d "/sys/devices/platform/mali-*.0" ]; then
	gpu="/sys/devices/platform/mali-*.0"
elif [ -d "/sys/module/mali/parameters" ]; then
	gpu="/sys/module/mali/parameters"
elif [ -d "/sys/class/misc/mali0" ]; then
	gpu="/sys/class/misc/mali0"
elif [ -d "/sys/kernel/gpu" ]; then
	gpu="/sys/kernel/gpu"
fi

if [ -e /proc/gpufreq/gpufreq_limited_thermal_ignore ]; then
echo "1" > /proc/gpufreq/gpufreq_limited_thermal_ignore
echo "$date Disabled gpufreq thermal" >> $LOG;
fi;

if [ -e /proc/mali/dvfs_enable ]; then
echo "1" > /proc/mali/dvfs_enable
echo "$date dvfs enabled" >> $LOG;
fi;

if [ -e /sys/module/simple_gpu_algorithm/parameters/simple_gpu_activate ]; then
echo "1" > /sys/module/simple_gpu_algorithm/parameters/simple_gpu_activate
echo "Y" > /sys/module/simple_gpu_algorithm/parameters/simple_gpu_activate
echo "$date Simple GPU algorithm enabled" >> $LOG;
fi;

# Adreno idler
if [ -e /sys/module/adreno_idler/parameters/adreno_idler_active ];  then
echo "Y" > /sys/module/adreno_idler/parameters/adreno_idler_active
echo "6000" > /sys/module/adreno_idler/parameters/adreno_idler_idleworkload
echo "15" > /sys/module/adreno_idler/parameters/adreno_idler_downdifferential
echo "15" > /sys/module/adreno_idler/parameters/adreno_idler_idlewait
echo "$date Disabled adreno idler" >> $LOG;
fi;

if [ -e $gpu/devfreq/adrenoboost ]; then
 echo "2" > $gpu/devfreq/adrenoboost
 echo "$date Adreno boost is set to 2" >> $LOG;
fi;

if [ -e $gpu/throttling ]; then
echo "0" > $gpu/throttling
echo "$date GPU throttling disabled" >> $LOG;
fi;

if [ -e $gpu/max_pwrlevel ]; then
echo "0" > $gpu/max_pwrlevel
echo "$date GPU max power level disabled" >> $LOG;
fi;

if [ -e $gpu/force_no_nap ]; then
echo "1" > $gpu/force_no_nap
echo "$date force_no_nap enabled" >> $LOG;
fi;

if [ -e $gpu/bus_split ]; then
echo "0" > $gpu/bus_split
echo "$date bus_split disabled" >> $LOG;
fi;

if [ -e $gpu/force_bus_on ]; then
echo "1" > $gpu/force_bus_on
echo "$date force_bus_on enabled" >> $LOG;
fi;

if [ -e $gpu/force_clk_on ]; then
echo "1" > $gpu/force_clk_on
echo "$date force_clk_on enabled" >> $LOG;
fi;

if [ -e $gpu/force_rail_on ]; then
echo "1" > $gpu/force_rail_on
echo "$date force_rail_on enabled" >> $LOG;
fi;

echo "$date GPU is optimized..." >> $LOG;
}

gpuOptimizerPowerSaving() {
echo "$date Optimizing GPU..." >> $LOG;

# GPU related tweaks
if [ -d "/sys/class/kgsl/kgsl-3d0" ]; then
	gpu="/sys/class/kgsl/kgsl-3d0"
elif [ -d "/sys/devices/platform/kgsl-3d0.0/kgsl/kgsl-3d0" ]; then
	gpu="/sys/devices/platform/kgsl-3d0.0/kgsl/kgsl-3d0"
elif [ -d "/sys/devices/soc/*.qcom,kgsl-3d0/kgsl/kgsl-3d0" ]; then
	gpu="/sys/devices/soc/*.qcom,kgsl-3d0/kgsl/kgsl-3d0"
elif [ -d "/sys/devices/soc.0/*.qcom,kgsl-3d0/kgsl/kgsl-3d0" ]; then
	gpu="/sys/devices/soc.0/*.qcom,kgsl-3d0/kgsl/kgsl-3d0"
elif [ -d "/sys/devices/platform/*.gpu/devfreq/*.gpu" ]; then
	gpu="/sys/devices/platform/*.gpu/devfreq/*.gpu"
elif [ -d "/sys/devices/platform/gpusysfs" ]; then
	gpu="/sys/devices/platform/gpusysfs"
elif [ -d "/sys/devices/*.mali" ]; then
	gpu="/sys/devices/*.mali"
elif [ -d "/sys/devices/*.gpu" ]; then
	gpu="/sys/devices/*.gpu"
elif [ -d "/sys/devices/platform/mali.0" ]; then
	gpu="/sys/devices/platform/mali.0"
elif [ -d "/sys/devices/platform/mali-*.0" ]; then
	gpu="/sys/devices/platform/mali-*.0"
elif [ -d "/sys/module/mali/parameters" ]; then
	gpu="/sys/module/mali/parameters"
elif [ -d "/sys/class/misc/mali0" ]; then
	gpu="/sys/class/misc/mali0"
elif [ -d "/sys/kernel/gpu" ]; then
	gpu="/sys/kernel/gpu"
fi

if [ -e /proc/gpufreq/gpufreq_limited_thermal_ignore ]; then
echo "1" > /proc/gpufreq/gpufreq_limited_thermal_ignore
echo "$date Disabled gpufreq thermal" >> $LOG;
fi;

if [ -e /proc/mali/dvfs_enable ]; then
echo "1" > /proc/mali/dvfs_enable
echo "$date dvfs enabled" >> $LOG;
fi;

if [ -e /sys/module/simple_gpu_algorithm/parameters/simple_gpu_activate ]; then
echo "1" > /sys/module/simple_gpu_algorithm/parameters/simple_gpu_activate
echo "Y" > /sys/module/simple_gpu_algorithm/parameters/simple_gpu_activate
echo "$date Simple GPU algorithm enabled" >> $LOG;
fi;

# Adreno idler
if [ -e /sys/module/adreno_idler/parameters/adreno_idler_active ];  then
echo "Y" > /sys/module/adreno_idler/parameters/adreno_idler_active
echo "10000" > /sys/module/adreno_idler/parameters/adreno_idler_idleworkload
echo "35" > /sys/module/adreno_idler/parameters/adreno_idler_downdifferential
echo "25" > /sys/module/adreno_idler/parameters/adreno_idler_idlewait
echo "$date Enabled and tweaked adreno idler" >> $LOG;
fi;

if [ -e $gpu/devfreq/adrenoboost ]; then
 echo "0" > $gpu/devfreq/adrenoboost
 echo "$date Adreno boost is set to 0" >> $LOG;
fi;

if [ -e $gpu/throttling ]; then
echo "0" > $gpu/throttling
echo "$date GPU throttling disabled" >> $LOG;
fi;

if [ -e $gpu/max_pwrlevel ]; then
echo "0" > $gpu/max_pwrlevel
echo "$date GPU max power level disabled" >> $LOG;
fi;

if [ -e $gpu/force_no_nap ]; then
echo "0" > $gpu/force_no_nap
echo "$date force_no_nap disabled" >> $LOG;
fi;

if [ -e $gpu/bus_split ]; then
echo "1" > $gpu/bus_split
echo "$date bus_split enabled" >> $LOG;
fi;

if [ -e $gpu/force_bus_on ]; then
echo "0" > $gpu/force_bus_on
echo "$date force_bus_on disabled" >> $LOG;
fi;

if [ -e $gpu/force_clk_on ]; then
echo "0" > $gpu/force_clk_on
echo "$date force_clk_on disabled" >> $LOG;
fi;

if [ -e $gpu/force_rail_on ]; then
echo "0" > $gpu/force_rail_on
echo "$date force_rail_on disabled" >> $LOG;
fi;

echo "$date GPU is optimized..." >> $LOG;
}

optimizeBuffers() {
echo "$date Changing GPU buffer count" >> $LOG;

setprop debug.egl.buffcount 4

echo "$date GPU buffer count set to 4" >> $LOG;
}

renderOpenglesUsingGpu() {
echo "$date Setting GPU to render OpenGLES..." >> $LOG;

setprop debug.egl.hw 1

echo "$date GPU successfully set up to render OpenGLES" >> $LOG;
}

useOpenglSkia() {
echo "$date Changing app rendering to skiagl..." >> $LOG;

setprop debug.hwui.renderer skiagl

echo "$date Rendering chaned to skiagl" >> $LOG;
}

disableIoStats() {
echo "$date Disabling I/O Stats..." >> $LOG;

for i in $(find /sys -name iostats);
do
echo "0" > "$i";
echo "$date iostats=0 in $i" >> $LOG;
done

echo "$date I/O Stats disabled" >> $LOG;
}

ioBlocksOptimizationBalanced() {
echo "$date Activating balanced I/O blocks optimization..." >> $LOG;

for i in $(find /sys -name add_random);
do
echo "0" > "$i";
echo "$date add_random=0 in $i" >> $LOG;
done

for i in $(find /sys -name nomerges);
do
echo "0" > "$i";
echo "$date nomerges=0 in $i" >> $LOG;
done

for i in $(find /sys -name rq_affinity);
do
echo "1" > "$i";
echo "$date rq_affinity=1 in $i" >> $LOG;
done

for i in $(find /sys -name nr_requests);
do
echo "128" > "$i";
echo "$date nr_requests=128 in $i" >> $LOG;
done

for i in $(find /sys -name read_ahead_kb);
do
echo "128" > "$i";
echo "$date read_ahead_kb=128 in $i" >> $LOG;
done

for i in $(find /sys -name io_poll);
do
echo "0" > "$i";
echo "$date io_poll=0 in $i" >> $LOG;
done

for i in $(find /sys -name write_cache);
do
echo "write through" > "$i";
echo "$date write_cache=write through in $i" >> $LOG;
done

# MMC CRC disabled
removable=/sys/module/mmc_core/parameters/removable
if [ -e $removable ]; then
echo "N" > $removable
echo "$date CRC Checks disabled $removable" >> $LOG;
fi;

crc=/sys/module/mmc_core/parameters/crc
if [ -e $crc ]; then
echo "N" > $crc
echo "$date CRC Checks disabled $crc" >> $LOG;
fi;

use_spi_crc=/sys/module/mmc_core/parameters/use_spi_crc
if [ -e $use_spi_crc ]; then
echo "N" > $use_spi_crc
echo "$date CRC Checks disabled $use_spi_crc" >> $LOG;
fi;

echo "$date Balanced I/O blocks optimization activated" >> $LOG;
}

ioBlocksOptimizationPerformance() {
echo "$date Activating performance I/O blocks optimization..." >> $LOG;

for i in $(find /sys -name add_random);
do
echo "0" > "$i";
echo "$date add_random=0 in $i" >> $LOG;
done

for i in $(find /sys -name nomerges);
do
echo "0" > "$i";
echo "$date nomerges=0 in $i" >> $LOG;
done

for i in $(find /sys -name rq_affinity);
do
echo "2" > "$i";
echo "$date rq_affinity=2 in $i" >> $LOG;
done

for i in $(find /sys -name nr_requests);
do
echo "128" > "$i";
echo "$date nr_requests=128 in $i" >> $LOG;
done

for i in $(find /sys -name read_ahead_kb);
do
echo "128" > "$i";
echo "$date read_ahead_kb=128 in $i" >> $LOG;
done

for i in $(find /sys -name io_poll);
do
echo "0" > "$i";
echo "$date io_poll=0 in $i" >> $LOG;
done

for i in $(find /sys -name write_cache);
do
echo "write through" > "$i";
echo "$date write_cache=write through in $i" >> $LOG;
done

# MMC CRC disabled
removable=/sys/module/mmc_core/parameters/removable
if [ -e $removable ]; then
echo "N" > $removable
echo "$date CRC Checks disabled $removable" >> $LOG;
fi;

crc=/sys/module/mmc_core/parameters/crc
if [ -e $crc ]; then
echo "N" > $crc
echo "$date CRC Checks disabled $crc" >> $LOG;
fi;

use_spi_crc=/sys/module/mmc_core/parameters/use_spi_crc
if [ -e $use_spi_crc ]; then
echo "N" > $use_spi_crc
echo "$date CRC Checks disabled $use_spi_crc" >> $LOG;
fi;

echo "$date Performance I/O blocks optimization activated" >> $LOG;
}

ioBlocksOptimizationPowerSaving() {
echo "$date Activating power saving I/O blocks optimization..." >> $LOG;

for i in $(find /sys -name add_random);
do
echo "0" > "$i";
echo "$date add_random=0 in $i" >> $LOG;
done

for i in $(find /sys -name nomerges);
do
echo "0" > "$i";
echo "$date nomerges=0 in $i" >> $LOG;
done

for i in $(find /sys -name rq_affinity);
do
echo "0" > "$i";
echo "$date rq_affinity=0 in $i" >> $LOG;
done

for i in $(find /sys -name nr_requests);
do
echo "64" > "$i";
echo "$date nr_requests=64 in $i" >> $LOG;
done

for i in $(find /sys -name read_ahead_kb);
do
echo "64" > "$i";
echo "$date read_ahead_kb=64 in $i" >> $LOG;
done

for i in $(find /sys -name io_poll);
do
echo "0" > "$i";
echo "$date io_poll=0 in $i" >> $LOG;
done

for i in $(find /sys -name write_cache);
do
echo "write through" > "$i";
echo "$date write_cache=write through in $i" >> $LOG;
done

# MMC CRC disabled
removable=/sys/module/mmc_core/parameters/removable
if [ -e $removable ]; then
echo "N" > $removable
echo "$date CRC Checks disabled $removable" >> $LOG;
fi;

crc=/sys/module/mmc_core/parameters/crc
if [ -e $crc ]; then
echo "N" > $crc
echo "$date CRC Checks disabled $crc" >> $LOG;
fi;

use_spi_crc=/sys/module/mmc_core/parameters/use_spi_crc
if [ -e $use_spi_crc ]; then
echo "N" > $use_spi_crc
echo "$date CRC Checks disabled $use_spi_crc" >> $LOG;
fi;

echo "$date Power saving I/O blocks optimization activated" >> $LOG;
}

ioExtendedQueue() {
echo "$date Activating I/O extend queue..." >> $LOG;

mmc=`ls -d /sys/block/mmc*`;
sd=`ls -d /sys/block/sd*`;

for i in $mmc $sd
do
echo "512" > "$i";
echo "$date nr_requests=512 in $i" >> $LOG;
done

echo "$date I/O extend queue is activated" >> $LOG;

}

partitionRemount() {
echo "$date Remounting partitions for better IO speed..." >> $LOG;

for ext4 in $(mount | grep ext4 | cut -d " " -f3);
do
mount -o remount,noatime -t auto "$ext4"
done

echo "$date Remounting finished" >> $LOG;
}

dnsOptimizationzCloudFlare() {
echo "$date Activating DNS optimization..." >> $LOG;

iptables -t nat -A OUTPUT -p udp --dport 53 -j DNAT --to 1.0.0.1:53
iptables -t nat -I OUTPUT -p udp --dport 53 -j DNAT --to 1.0.0.1:53
iptables -t nat -A OUTPUT -p tcp --dport 53 -j DNAT --to 1.1.1.1:53
iptables -t nat -I OUTPUT -p tcp --dport 53 -j DNAT --to 1.1.1.1:53
ip6tables -t nat -A OUTPUT -p tcp --dport 53 -j DNAT --to  2606:4700:4700::1111
ip6tables -t nat -A OUTPUT -p tcp --dport 53 -j DNAT --to  2606:4700:4700::1001
ip6tables -t nat -I OUTPUT -p tcp --dport 53 -j DNAT --to  2606:4700:4700::1111
ip6tables -t nat -I OUTPUT -p udp --dport 53 -j DNAT --to  2606:4700:4700::1001

setprop net.eth0.dns1 1.1.1.1
setprop net.eth0.dns2 1.0.0.1
setprop net.dns1 1.1.1.1
setprop net.dns2 1.0.0.1
setprop net.ppp0.dns1 1.1.1.1
setprop net.ppp0.dns2 1.0.0.1
setprop net.rmnet0.dns1 1.1.1.1
setprop net.rmnet0.dns2 1.0.0.1
setprop net.rmnet1.dns1 1.1.1.1
setprop net.rmnet1.dns2 1.0.0.1
setprop net.rmnet2.dns1 1.1.1.1
setprop net.rmnet2.dns2 1.0.0.1
setprop net.pdpbr1.dns1 1.1.1.1
setprop net.pdpbr1.dns2 1.0.0.1
setprop net.wlan0.dns1 1.1.1.1
setprop net.wlan0.dns2 1.0.0.1
setprop 2606:4700:4700::1111
setprop 2606:4700:4700::1001

echo "$date Changing DNS to CloudFlare" >> $LOG;

echo "$date DNS optimization is activated" >> $LOG;
}

dnsOptimizationGooglePublic() {
echo "$date Activating DNS optimization..." >> $LOG;

iptables -t nat -A OUTPUT -p udp --dport 53 -j DNAT --to 8.8.8.8:53
iptables -t nat -I OUTPUT -p udp --dport 53 -j DNAT --to 8.8.4.4:53
iptables -t nat -A OUTPUT -p tcp --dport 53 -j DNAT --to 8.8.8.8:53
iptables -t nat -I OUTPUT -p tcp --dport 53 -j DNAT --to 8.8.4.4:53
ip6tables -t nat -A OUTPUT -p tcp --dport 53 -j DNAT --to 2001:4860:4860:8888
ip6tables -t nat -I OUTPUT -p tcp --dport 53 -j DNAT --to 2001:4860:4860:8888
ip6tables -t nat -A OUTPUT -p udp --dport 53 -j DNAT --to 2001:4860:4860:8844
ip6tables -t nat -I OUTPUT -p udp --dport 53 -j DNAT --to 2001:4860:4860:8844

setprop net.eth0.dns1 8.8.8.8
setprop net.eth0.dns2 8.8.4.4
setprop net.dns1 8.8.8.8
setprop net.dns2 8.8.4.4
setprop net.ppp0.dns1 8.8.8.8
setprop net.ppp0.dns2 8.8.4.4
setprop net.rmnet0.dns1 8.8.8.8
setprop net.rmnet0.dns2 8.8.4.4
setprop net.rmnet1.dns1 8.8.8.8
setprop net.rmnet1.dns2 8.8.4.4
setprop net.rmnet2.dns1 8.8.8.8
setprop net.rmnet2.dns2 8.8.4.4
setprop net.pdpbr1.dns1 8.8.8.8
setprop net.pdpbr1.dns2 8.8.4.4
setprop net.wlan0.dns1 8.8.8.8
setprop net.wlan0.dns2 8.8.4.4
setprop 2001:4860:4860::8888
setprop 2001:4860:4860::8844

echo "$date Changing DNS to Google Public" >> $LOG;

echo "$date DNS optimization is activated" >> $LOG;
}

netBuffersBig() {
echo "$date Activating big net buffers..." >> $LOG;

# Define TCP buffer sizes for various networks
# ReadMin, ReadInitial, ReadMax, WriteMin, WriteInitial, WriteMax
setprop net.tcp.buffersize.default 6144,87380,1048576,6144,87380,524288
setprop net.tcp.buffersize.wifi 524288,1048576,2097152,524288,1048576,2097152
setprop net.tcp.buffersize.umts 6144,87380,1048576,6144,87380,524288
setprop net.tcp.buffersize.gprs 6144,87380,1048576,6144,87380,524288
setprop net.tcp.buffersize.edge 6144,87380,524288,6144,16384,262144
setprop net.tcp.buffersize.hspa 6144,87380,524288,6144,16384,262144
setprop net.tcp.buffersize.lte 524288,1048576,2097152,524288,1048576,2097152
setprop net.tcp.buffersize.hsdpa 6144,87380,1048576,6144,87380,1048576
setprop net.tcp.buffersize.evdo_b 6144,87380,1048576,6144,87380,1048576

echo "$date Big net buffers activated" >> $LOG;
}

netBuffersSmall() {
echo "$date Activating small net buffers..." >> $LOG;

# Define TCP buffer sizes for various networks
# ReadMin, ReadInitial, ReadMax, WriteMin, WriteInitial, WriteMax
setprop net.tcp.buffersize.hspa 4096,32768,65536,4096,32768,65536
setprop net.tcp.buffersize.umts 4096,32768,65536,4096,32768,65536
setprop net.tcp.buffersize.edge 4096,32768,65536,4096,32768,65536
setprop net.tcp.buffersize.gprs 4096,32768,65536,4096,32768,65536
setprop net.tcp.buffersize.hsdpa 4096,32768,65536,4096,32768,65536
setprop net.tcp.buffersize.wifi 4096,32768,65536,4096,32768,65536
setprop net.tcp.buffersize.evdo_b 4096,32768,65536,4096,32768,65536
setprop net.tcp.buffersize.lte 4096,32768,65536,4096,32768,65536
setprop net.tcp.buffersize.default 4096,32768,12582912,4096,32768,12582912

echo "$date Small net buffers activated" >> $LOG;
}

netSpeedPlus() {
echo "$date Activating Net Speed+..." >> $LOG;

for i in $(ls /sys/class/net); do
echo "128" > /sys/class/net/"$i"/tx_queue_len
echo "$date tx_queue_len=128 in $i" >> $LOG;
done

#for i in $(ls /sys/class/net); do
#echo "1500" > /sys/class/net/"$i"/mtu
#echo "$date mtu=1500 in $i" >> $LOG;
#done

echo "$date Net Speed+ activated" >> $LOG;
}

netTcpTweaks() {
echo "$date Activating TCP tweak..." >> $LOG;

#echo "128" > /proc/sys/net/core/netdev_max_backlog
#echo "0" > /proc/sys/net/core/netdev_tstamp_prequeue
#echo "0" > /proc/sys/net/ipv4/cipso_cache_bucket_size
#echo "0" > /proc/sys/net/ipv4/cipso_cache_enable
#echo "0" > /proc/sys/net/ipv4/cipso_rbm_strictvalid
#echo "0" > /proc/sys/net/ipv4/igmp_link_local_mcast_reports
#echo "24" > /proc/sys/net/ipv4/ipfrag_time
#echo "1" > /proc/sys/net/ipv4/tcp_ecn
#echo "0" > /proc/sys/net/ipv4/tcp_fwmark_accept
#echo "320" > /proc/sys/net/ipv4/tcp_keepalive_intvl
#echo "21600" > /proc/sys/net/ipv4/tcp_keepalive_time
#echo "1" > /proc/sys/net/ipv4/tcp_no_metrics_save
#echo "1800" > /proc/sys/net/ipv4/tcp_probe_interval
#echo "0" > /proc/sys/net/ipv4/tcp_slow_start_after_idle
#echo "48" > /proc/sys/net/ipv6/ip6frag_time

echo "0" > /proc/sys/net/ipv4/conf/default/secure_redirects
echo "0" > /proc/sys/net/ipv4/conf/default/accept_redirects
echo "0" > /proc/sys/net/ipv4/conf/default/accept_source_route
echo "0" > /proc/sys/net/ipv4/conf/all/secure_redirects
echo "0" > /proc/sys/net/ipv4/conf/all/accept_redirects
echo "0" > /proc/sys/net/ipv4/conf/all/accept_source_route
echo "0" > /proc/sys/net/ipv4/ip_forward
echo "0" > /proc/sys/net/ipv4/ip_dynaddr
echo "0" > /proc/sys/net/ipv4/ip_no_pmtu_disc
echo "0" > /proc/sys/net/ipv4/tcp_ecn
echo "0" > /proc/sys/net/ipv4/tcp_timestamps
echo "1" > /proc/sys/net/ipv4/tcp_tw_reuse
echo "1" > /proc/sys/net/ipv4/tcp_fack
echo "1" > /proc/sys/net/ipv4/tcp_sack
echo "1" > /proc/sys/net/ipv4/tcp_dsack
echo "1" > /proc/sys/net/ipv4/tcp_rfc1337
echo "1" > /proc/sys/net/ipv4/tcp_tw_recycle
echo "1" > /proc/sys/net/ipv4/tcp_window_scaling
echo "1" > /proc/sys/net/ipv4/tcp_moderate_rcvbuf
echo "1" > /proc/sys/net/ipv4/tcp_no_metrics_save
echo "2" > /proc/sys/net/ipv4/tcp_synack_retries
echo "2" > /proc/sys/net/ipv4/tcp_syn_retries
echo "5" > /proc/sys/net/ipv4/tcp_keepalive_probes
echo "30" > /proc/sys/net/ipv4/tcp_keepalive_intvl
echo "30" > /proc/sys/net/ipv4/tcp_fin_timeout
echo "1800" > /proc/sys/net/ipv4/tcp_keepalive_time
echo "261120" > /proc/sys/net/core/rmem_max
echo "261120" > /proc/sys/net/core/wmem_max
echo "261120" > /proc/sys/net/core/rmem_default
echo "261120" > /proc/sys/net/core/wmem_default

echo "$date TCP tweak activated" >> $LOG;

}

rilTweaks() {
echo "$date Activating ril tweaks..." >> $LOG;

setprop ro.ril.gprsclass 12
echo "$date GPRS Class changed to 12" >> $LOG;

setprop ro.ril.hsdpa.category 28
echo "$date hsdpa category changed to 28" >> $LOG;

setprop ro.ril.hsupa.category 7
echo "$date hsupa category changed to 7" >> $LOG;

setprop ro.telephony.call_ring.delay 1500
echo "$date RING/CRING event delay reduced to 1.5sec" >> $LOG;

setprop ro.telephony.call_ring.multiple false
echo "$date Ril sends only one RIL_UNSOL_CALL_RING, so set call_ring.multiple to false" >> $LOG;

echo "$date Ril tweaks are activated" >> $LOG;
}

disableDebugging() {
echo "$date Powerful logging disable started..." >> $LOG;

for i in $(find /sys -name debug_mask); do
 echo "0" > "$i"
 echo "$date Disabled debugging for $i" >> $LOG;
done

for i in $(find /sys -name debug); do
 echo "0" > "$i"
 echo "$date Disabled debugging for $i" >> $LOG;
done

for i in $(find /sys -name debug_enable); do
 echo "0" > "$i"
 echo "$date Disabled debugging for $i" >> $LOG;
done

for i in $(find /sys -name debug_level); do
echo "0" > "$i"
echo "$date Disabled debugging for $i" >> $LOG;
done

for i in $(find /sys -name edac_mc_log_ce); do
echo "0" > "$i"
echo "$date Disabled debugging for $i" >> $LOG;
done

for i in $(find /sys -name edac_mc_log_ue); do
echo "0" > "$i"
echo "$date Disabled debugging for $i" >> $LOG;
done

for i in $(find /sys -name pwrnap); do
echo "0" > "$i"
echo "$date Disabled debugging for $i" >> $LOG;
done

for i in $(find /sys -name enable_event_log); do
echo "0" > "$i"
echo "$date Disabled debugging for $i" >> $LOG;
done

for i in $(find /sys -name log_ecn_error); do
echo "0" > "$i"
echo "$date Disabled debugging for $i" >> $LOG;
done

for i in $(find /sys -name snapshot_crashdumper); do
echo "0" > "$i"
echo "$date Disabled debugging for $i" >> $LOG;
done

setprop ro.config.nocheckin 1
setprop profiler.force_disable_err_rpt 1
echo "$date Force disabled error reporting" >> $LOG;

console_suspend=/sys/module/printk/parameters/console_suspend
if [ -e $console_suspend ]; then
echo "Y" > $console_suspend
echo "$date Console suspended" >> $LOG;
fi;

log_mode=/sys/module/logger/parameters/log_mode
if [ -e $LOG_mode ]; then
echo "2" > $LOG_mode
echo "$date Logger disabled" >> $LOG;
fi;

debug_enabled=/sys/kernel/debug/debug_enabled
if [ -e $debug_enabled ]; then
echo "N" > $debug_enabled
echo "$date Disabled kernel debugging" >> $LOG;
fi;

exception_trace=/proc/sys/debug/exception-trace
if [ -e "$exception_trace" ]; then
echo "0" > "$exception_trace"
echo "$date Disabled exception-trace debugger" >> $LOG;
fi;

mali_debug_level=/sys/module/mali/parameters/mali_debug_level
if [ -e $mali_debug_level ]; then
echo "0" > $mali_debug_level
echo "$date Disabled mali GPU debugging" >> $LOG;
fi;

block_dump=/proc/sys/vm/block_dump
if [ -e $block_dump ]; then
echo "0" > $block_dump
echo "$date Disabled I/O block debugging" >> $LOG;
fi;

mballoc_debug=/sys/module/ext4/parameters/mballoc_debug
if [ -e $mballoc_debug ]; then
echo "0" > $mballoc_debug
echo "$date Disabled ext4 runtime debugging" >> $LOG;
fi;

logger_mode=/sys/kernel/logger_mode/logger_mode
if [ -e $LOGger_mode ]; then
echo "0" > $LOGger_mode
echo "$date Logger disabled" >> $LOG;
fi;

log_enabled=/sys/module/logger/parameters/log_enabled
if [ -e $LOG_enabled ]; then
echo "0" > $LOG_enabled
echo "$date Logger disabled" >> $LOG;
fi;

logger_enabled=/sys/module/logger/parameters/enabled
if [ -e $LOGger_enabled ]; then
echo "0" > $LOGger_enabled
echo "$date Logger disabled" >> $LOG;
fi;

compat_log=/proc/sys/kernel/compat-log
if [ -e $compat_log ]; then
echo "0" > $compat_log
echo "$date Compat logging disabled" >> $LOG;
fi;

disable_ertm=/sys/module/bluetooth/parameters/disable_ertm
if [ -e $disable_ertm ]; then
echo "0" > $disable_ertm
echo "$date Bluetooth ertm disabled" >> $LOG;
fi;

disable_esco=/sys/module/bluetooth/parameters/disable_esco
if [ -e $disable_esco ]; then
echo "0" > $disable_esco
echo "$date Bluetooth esco is disabled" >> $LOG;
fi;

echo "$date Logging disabled..." >> $LOG;
}

disableKernelPanic() {
echo "$date Disabling kernel panic..." >> $LOG;

sysctl -e -w vm.panic_on_oom=0
sysctl -e -w kernel.panic_on_oops=0
sysctl -e -w kernel.panic=0
sysctl -e -w kernel.panic_on_warn=0

echo "$date Kernel panic disabled" >> $LOG;
}

disableMultitaskingLimitations() {
echo "$date Disabling multitasking limitations..." >> $LOG;

setprop MIN_HIDDEN_APPS false
echo "$date MIN_HIDDEN_APPS=false" >> $LOG;

setprop ACTIVITY_INACTIVE_RESET_TIME false
echo "$date ACTIVITY_INACTIVE_RESET_TIME=false" >> $LOG;

setprop MIN_RECENT_TASKS false
echo "$date MIN_RECENT_TASKS=false" >> $LOG;

setprop PROC_START_TIMEOUT false
echo "$date PROC_START_TIMEOUT=false" >> $LOG;

setprop CPU_MIN_CHECK_DURATION false
echo "$date CPU_MIN_CHECK_DURATION=false" >> $LOG;

setprop GC_TIMEOUT false
echo "$date GC_TIMEOUT=false" >> $LOG;

setprop SERVICE_TIMEOUT false
echo "$date SERVICE_TIMEOUT=false" >> $LOG;

setprop MIN_CRASH_INTERVAL false
echo "$date MIN_CRASH_INTERVAL=false" >> $LOG;

setprop ENFORCE_PROCESS_LIMIT false
echo "$date ENFORCE_PROCESS_LIMIT=false" >> $LOG;

echo "$date Multitasking limitations disabled" >> $LOG;
}

lowRamFlagDisabled() {
echo "$date Disabling low RAM flag..." >> $LOG;

setprop ro.config.low_ram false

echo "$date Low RAM flag disabled" >> $LOG;
}

lowRamFlagEnabled() {
echo "$date Enabling low RAM flag..." >> $LOG;

setprop ro.config.low_ram true

echo "$date Low RAM flag enabled" >> $LOG;
}

oomKillerDisabled() {
echo "$date Disabled OOM killer..." >> $LOG;

oom_kill_allocating_task=/proc/sys/vm/oom_kill_allocating_task
if [ -e $oom_kill_allocating_task ]; then
echo "0" > $oom_kill_allocating_task
fi;

echo "$date OOM killer disabled" >> $LOG;
}

oomKillerEnabled() {
echo "$date Enabling OOM killer..." >> $LOG;

oom_kill_allocating_task=/proc/sys/vm/oom_kill_allocating_task
if [ -e $oom_kill_allocating_task ]; then
echo "1" > $oom_kill_allocating_task
fi;

echo "$date OOM killer enabled" >> $LOG;
}

ramManagerBalanced() {

memTotal=$(free -m | awk '/^Mem:/{print $2}');

fa=$(((memTotal*2/100)*1024/4));
va=$(((memTotal*3/100)*1024/4));
ss=$(((memTotal*5/100)*1024/4));
ha=$(((memTotal*6/100)*1024/4));
cp=$(((memTotal*9/100)*1024/4));
ea=$(((memTotal*11/100)*1024/4));
minFree="$fa,$va,$ss,$ha,$cp,$ea";

# Higher values of oom_adj are more likely
# to be killed by the kernel's oom killer.
# The current foreground app has a oom_adj of 0
adj="0,112,224,408,824,1000";

# If you set this to lower than 1024KB, your system will
# become subtly broken, and prone to deadlock under high loads, we don't allow it below 2048kb
mfk=$((memTotal*3));

if [ "$mfk" -le "4096" ]; then
mfk=4096;
fi;

# Extra free kbytes should not be bigger than min free kbytes
efk=$mfk/2;

if [ "$efk" -le "2048" ]; then
efk=2048;
fi;

# Background app limit per ram size
if [ "$memTotal" -le "1024" ]; then
backgroundAppLimit="24";
elif [ "$memTotal" -le "2048" ]; then
backgroundAppLimit="28";
elif [ "$memTotal" -le "3072" ]; then
backgroundAppLimit="30";
elif [ "$memTotal" -le "4096" ]; then
backgroundAppLimit="36";
else
backgroundAppLimit="42";
fi;

# Set 1 to reclaim resources quickly when needed.
fastRun="0";

oomReaper="1";
adaptiveLmk="0";

# How much memory of swap will be counted as free
fudgeSwap="1024";

echo "$date Enabling balanced RAM manager profile" >> $LOG;

sync
sysctl -w vm.drop_caches=3;

setprop ro.sys.fw.bg_apps_limit $backgroundAppLimit;
setprop ro.vendor.qti.sys.fw.bg_apps_limit $backgroundAppLimit;
echo "$date Background app limit=$backgroundAppLimit" >> $LOG;

parameter_adj=/sys/module/lowmemorykiller/parameters/adj;
if [ -e $parameter_adj ]; then
chmod 0666 $parameter_adj;
echo "$adj" > $parameter_adj;
echo "$date adj=$adj" >> $LOG;
fi;

parameter_oom_reaper=/sys/module/lowmemorykiller/parameters/oom_reaper;
if [ -e $parameter_oom_reaper ]; then
chmod 0666 $parameter_oom_reaper;
echo "$oomReaper" > $parameter_oom_reaper;
echo "$date oom_reaper=$oomReaper" >> $LOG;
fi;

parameter_lmk_fast_run=/sys/module/lowmemorykiller/parameters/lmk_fast_run;
if [ -e $parameter_lmk_fast_run ]; then
chmod 0666 $parameter_lmk_fast_run;
echo "$fastRun" > $parameter_lmk_fast_run;
echo "$date lmk_fast_run=$fastRun" >> $LOG;
fi;

parameter_adaptive_lmk=/sys/module/lowmemorykiller/parameters/enable_adaptive_lmk;
if [ -e $parameter_adaptive_lmk ]; then
chmod 0666 $parameter_adaptive_lmk;
echo "$adaptiveLmk" > $parameter_adaptive_lmk;
setprop lmk.autocalc false;
echo "$date adaptive_lmk=$adaptiveLmk" >> $LOG;
fi;

parameter_fudge_swap=/sys/module/lowmemorykiller/parameters/fudgeswap;
if [ -e $parameter_fudge_swap ]; then
chmod 0666 $parameter_fudge_swap;
echo "$fudgeSwap" > $parameter_fudge_swap;
echo "$date fudge_swap=$fudgeSwap" >> $LOG;
fi;

parameter_minfree=/sys/module/lowmemorykiller/parameters/minfree;
if [ -e $parameter_minfree ]; then
chmod 0666 $parameter_minfree;
echo "$minFree" > $parameter_minfree;
echo "$date minfree=$minFree" >> $LOG;
fi;

parameter_min_free_kbytes=/proc/sys/vm/min_free_kbytes;
if [ -e $parameter_min_free_kbytes ]; then
chmod 0666 $parameter_min_free_kbytes;
echo "$mfk" > $parameter_min_free_kbytes;
echo "$date min_free_kbytes=$mfk" >> $LOG;
fi;

parameter_extra_free_kbytes=/proc/sys/vm/extra_free_kbytes;
if [ -e $parameter_extra_free_kbytes ]; then
chmod 0666 $parameter_extra_free_kbytes;
echo "$efk" > $parameter_extra_free_kbytes;
echo "$date extra_free_kbytes=$efk" >> $LOG;
fi;

echo "$date Balanced RAM manager profile for $((memTotal))mb devices successfully applied" >> $LOG;
}

ramManagerGaming() {

memTotal=$(free -m | awk '/^Mem:/{print $2}');

fa=$(((memTotal*3/100)*1024/4));
va=$(((memTotal*4/100)*1024/4));
ss=$(((memTotal*5/100)*1024/4));
ha=$(((memTotal*7/100)*1024/4));
cp=$(((memTotal*10/100)*1024/4));
ea=$(((memTotal*14/100)*1024/4));
minFree="$fa,$va,$ss,$ha,$cp,$ea";

# Higher values of oom_adj are more likely
# to be killed by the kernel's oom killer.
# The current foreground app has a oom_adj of 0
adj="0,112,224,408,824,1000";

# If you set this to lower than 1024KB, your system will
# become subtly broken, and prone to deadlock under high loads, we don't allow it below 2048kb
mfk=$((memTotal*3));

if [ "$mfk" -le "4096" ]; then
mfk=4096;
fi;

# Extra free kbytes should not be bigger than min free kbytes
efk=$mfk/2;

if [ "$efk" -le "2048" ]; then
efk=2048;
fi;

# Background app limit per ram size
if [ "$memTotal" -le "1024" ]; then
backgroundAppLimit="18";
elif [ "$memTotal" -le "2048" ]; then
backgroundAppLimit="22";
elif [ "$memTotal" -le "3072" ]; then
backgroundAppLimit="26";
elif [ "$memTotal" -le "4096" ]; then
backgroundAppLimit="30";
else
backgroundAppLimit="42";
fi;

# Set 1 to reclaim resources quickly when needed.
fastRun="1";

oomReaper="1";
adaptiveLmk="0";

# How much memory of swap will be counted as free
fudgeSwap="1024";

echo "$date Enabling gaming RAM manager profile" >> $LOG;

sync
sysctl -w vm.drop_caches=3;

setprop ro.sys.fw.bg_apps_limit $backgroundAppLimit;
setprop ro.vendor.qti.sys.fw.bg_apps_limit $backgroundAppLimit;
echo "$date Background app limit=$backgroundAppLimit" >> $LOG;

parameter_adj=/sys/module/lowmemorykiller/parameters/adj;
if [ -e $parameter_adj ]; then
chmod 0666 $parameter_adj;
echo "$adj" > $parameter_adj;
echo "$date adj=$adj" >> $LOG;
fi;

parameter_oom_reaper=/sys/module/lowmemorykiller/parameters/oom_reaper;
if [ -e $parameter_oom_reaper ]; then
chmod 0666 $parameter_oom_reaper;
echo "$oomReaper" > $parameter_oom_reaper;
echo "$date oom_reaper=$oomReaper" >> $LOG;
fi;

parameter_lmk_fast_run=/sys/module/lowmemorykiller/parameters/lmk_fast_run;
if [ -e $parameter_lmk_fast_run ]; then
chmod 0666 $parameter_lmk_fast_run;
echo "$fastRun" > $parameter_lmk_fast_run;
echo "$date lmk_fast_run=$fastRun" >> $LOG;
fi;

parameter_adaptive_lmk=/sys/module/lowmemorykiller/parameters/enable_adaptive_lmk;
if [ -e $parameter_adaptive_lmk ]; then
chmod 0666 $parameter_adaptive_lmk;
echo "$adaptiveLmk" > $parameter_adaptive_lmk;
setprop lmk.autocalc false;
echo "$date adaptive_lmk=$adaptiveLmk" >> $LOG;
fi;

parameter_fudge_swap=/sys/module/lowmemorykiller/parameters/fudgeswap;
if [ -e $parameter_fudge_swap ]; then
chmod 0666 $parameter_fudge_swap;
echo "$fudgeSwap" > $parameter_fudge_swap;
echo "$date fudge_swap=$fudgeSwap" >> $LOG;
fi;

parameter_minfree=/sys/module/lowmemorykiller/parameters/minfree;
if [ -e $parameter_minfree ]; then
chmod 0666 $parameter_minfree;
echo "$minFree" > $parameter_minfree;
echo "$date minfree=$minFree" >> $LOG;
fi;

parameter_min_free_kbytes=/proc/sys/vm/min_free_kbytes;
if [ -e $parameter_min_free_kbytes ]; then
chmod 0666 $parameter_min_free_kbytes;
echo "$mfk" > $parameter_min_free_kbytes;
echo "$date min_free_kbytes=$mfk" >> $LOG;
fi;

parameter_extra_free_kbytes=/proc/sys/vm/extra_free_kbytes;
if [ -e $parameter_extra_free_kbytes ]; then
chmod 0666 $parameter_extra_free_kbytes;
echo "$efk" > $parameter_extra_free_kbytes;
echo "$date extra_free_kbytes=$efk" >> $LOG;
fi;

echo "$date Gaming RAM manager profile for $((memTotal))mb devices successfully applied" >> $LOG;
}

ramManagerMultitasking() {

memTotal=$(free -m | awk '/^Mem:/{print $2}');

fa=$(((memTotal*2/100)*1024/4));
va=$(((memTotal*3/100)*1024/4));
ss=$(((memTotal*5/100)*1024/4));
ha=$(((memTotal*6/100)*1024/4));
cp=$(((memTotal*9/100)*1024/4));
ea=$(((memTotal*11/100)*1024/4));
minFree="$fa,$va,$ss,$ha,$cp,$ea";

# Higher values of oom_adj are more likely
# to be killed by the kernel's oom killer.
# The current foreground app has a oom_adj of 0
adj="0,112,224,408,824,1000";

# If you set this to lower than 1024KB, your system will
# become subtly broken, and prone to deadlock under high loads, we don't allow it below 2048kb
mfk=$((memTotal*3));

if [ "$mfk" -le "4096" ]; then
mfk=4096;
fi;

# Extra free kbytes should not be bigger than min free kbytes
efk=$mfk/2;

if [ "$efk" -le "2048" ]; then
efk=2048;
fi;

# Background app limit per ram size
if [ "$memTotal" -le "1024" ]; then
backgroundAppLimit="25";
elif [ "$memTotal" -le "2048" ]; then
backgroundAppLimit="30";
elif [ "$memTotal" -le "3072" ]; then
backgroundAppLimit="36";
elif [ "$memTotal" -le "4096" ]; then
backgroundAppLimit="42";
else
backgroundAppLimit="44";
fi;

# Set 1 to reclaim resources quickly when needed.
fastRun="0";

oomReaper="1";
adaptiveLmk="0";

# How much memory of swap will be counted as free
fudgeSwap="1024";

echo "$date Enabling multitasking RAM manager profile" >> $LOG;

sync
sysctl -w vm.drop_caches=3;

setprop ro.sys.fw.bg_apps_limit $backgroundAppLimit;
setprop ro.vendor.qti.sys.fw.bg_apps_limit $backgroundAppLimit;
echo "$date Background app limit=$backgroundAppLimit" >> $LOG;

parameter_adj=/sys/module/lowmemorykiller/parameters/adj;
if [ -e $parameter_adj ]; then
chmod 0666 $parameter_adj;
echo "$adj" > $parameter_adj;
echo "$date adj=$adj" >> $LOG;
fi;

parameter_oom_reaper=/sys/module/lowmemorykiller/parameters/oom_reaper;
if [ -e $parameter_oom_reaper ]; then
chmod 0666 $parameter_oom_reaper;
echo "$oomReaper" > $parameter_oom_reaper;
echo "$date oom_reaper=$oomReaper" >> $LOG;
fi;

parameter_lmk_fast_run=/sys/module/lowmemorykiller/parameters/lmk_fast_run;
if [ -e $parameter_lmk_fast_run ]; then
chmod 0666 $parameter_lmk_fast_run;
echo "$fastRun" > $parameter_lmk_fast_run;
echo "$date lmk_fast_run=$fastRun" >> $LOG;
fi;

parameter_adaptive_lmk=/sys/module/lowmemorykiller/parameters/enable_adaptive_lmk;
if [ -e $parameter_adaptive_lmk ]; then
chmod 0666 $parameter_adaptive_lmk;
echo "$adaptiveLmk" > $parameter_adaptive_lmk;
setprop lmk.autocalc false;
echo "$date adaptive_lmk=$adaptiveLmk" >> $LOG;
fi;

parameter_fudge_swap=/sys/module/lowmemorykiller/parameters/fudgeswap;
if [ -e $parameter_fudge_swap ]; then
chmod 0666 $parameter_fudge_swap;
echo "$fudgeSwap" > $parameter_fudge_swap;
echo "$date fudge_swap=$fudgeSwap" >> $LOG;
fi;

parameter_minfree=/sys/module/lowmemorykiller/parameters/minfree;
if [ -e $parameter_minfree ]; then
chmod 0666 $parameter_minfree;
echo "$minFree" > $parameter_minfree;
echo "$date minfree=$minFree" >> $LOG;
fi;

parameter_min_free_kbytes=/proc/sys/vm/min_free_kbytes;
if [ -e $parameter_min_free_kbytes ]; then
chmod 0666 $parameter_min_free_kbytes;
echo "$mfk" > $parameter_min_free_kbytes;
echo "$date min_free_kbytes=$mfk" >> $LOG;
fi;

parameter_extra_free_kbytes=/proc/sys/vm/extra_free_kbytes;
if [ -e $parameter_extra_free_kbytes ]; then
chmod 0666 $parameter_extra_free_kbytes;
echo "$efk" > $parameter_extra_free_kbytes;
echo "$date extra_free_kbytes=$efk" >> $LOG;
fi;

echo "$date Multitasking RAM manager profile for $((memTotal))mb devices successfully applied" >> $LOG;
}

swappinessTendency1() {
echo "$date Setting swappiness tendency..." >> $LOG;

swappiness=/proc/sys/vm/swappiness
if [ -e $swappiness ]; then
echo "1" > $swappiness
echo "$date swappiness=1" >> $LOG;
fi;

echo "$date Swappiness tendency set to 1" >> $LOG;
}

swappinessTendency10() {
echo "$date Setting swappiness tendency..." >> $LOG;

swappiness=/proc/sys/vm/swappiness
if [ -e $swappiness ]; then
echo "10" > $swappiness
echo "$date swappiness=10" >> $LOG;
fi;

echo "$date Swappiness tendency set to 10" >> $LOG;
}

swappinessTendency25() {
echo "$date Setting swappiness tendency..." >> $LOG;

swappiness=/proc/sys/vm/swappiness
if [ -e $swappiness ]; then
echo "25" > $swappiness
echo "$date swappiness=25" >> $LOG;
fi;

echo "$date Swappiness tendency set to 25" >> $LOG;
}

swappinessTendency50() {
echo "$date Setting swappiness tendency..." >> $LOG;

swappiness=/proc/sys/vm/swappiness
if [ -e $swappiness ]; then
echo "50" > $swappiness
echo "$date swappiness=50" >> $LOG;
fi;

echo "$date Swappiness tendency set to 50" >> $LOG;
}

swappinessTendency75() {
echo "$date Setting swappiness tendency..." >> $LOG;

swappiness=/proc/sys/vm/swappiness
if [ -e $swappiness ]; then
echo "75" > $swappiness
echo "$date swappiness=75" >> $LOG;
fi;

echo "$date Swappiness tendency set to 75" >> $LOG;
}

swappinessTendency100() {
echo "$date Setting swappiness tendency..." >> $LOG;

swappiness=/proc/sys/vm/swappiness
if [ -e $swappiness ]; then
echo "100" > $swappiness
echo "$date swappiness=100" >> $LOG;
fi;

echo "$date Swappiness tendency set to 100" >> $LOG;
}

virtualMemoryTweaksBalanced() {
echo "$date Activating balanced virtual memory tweaks..." >> $LOG;

sync

leases_enable=/proc/sys/fs/leases-enable
if [ -e $leases_enable ]; then
echo "1" > $leases_enable
echo "$date $leases_enable=1" >> $LOG;
fi;

# This file specifies the grace period (in seconds) that the kernel grants
# to a process holding a file lease after it has sent a signal to that process
# notifying it that another process is waiting to open the file.
# If the lease holder does not remove or downgrade the lease within this grace period,
# the kernel forcibly breaks the lease.

lease_break_time=/proc/sys/fs/lease-break-time
if [ -e $lease_break_time ]; then
echo "10" > $lease_break_time
echo "$date $lease_break_time=10" >> $LOG;
fi;

# dnotify is a signal used to notify a process about file/directory changes.
dir_notify_enable=/proc/sys/fs/dir-notify-enable
if [ -e $dir_notify_enable ]; then
echo "0" > $dir_notify_enable
echo "$date $dir_notify_enable=0" >> $LOG;
fi;

echo "$date File system parameters are updated" >> $LOG;

enable_process_reclaim=/sys/module/process_reclaim/parameters/enable_process_reclaim
if [ -e $enable_process_reclaim ]; then
echo "0" > $enable_process_reclaim
echo "$date Reclaiming pages of inactive tasks disabled" >> $LOG;
fi;

# This parameter tells how much of physical RAM to take when swap is full
overcommit_ratio=/proc/sys/vm/overcommit_ratio
if [ -e overcommit_ratio ]; then
echo "0" > $overcommit_ratio
echo "$date overcommit_ratio=0" >> $LOG;
fi;

oom_dump_tasks=/proc/sys/vm/oom_dump_tasks
if [ -e $oom_dump_tasks ]; then
echo "0" > $oom_dump_tasks
echo "$date OOM dump tasks are disabled" >> $LOG;
fi;

vfs_cache_pressure=/proc/sys/vm/vfs_cache_pressure
if [ -e $vfs_cache_pressure ]; then
echo "60" > $vfs_cache_pressure
echo "$date vfs_cache_pressure=60" >> $LOG;
fi;

laptop_mode=/proc/sys/vm/laptop_mode
if [ -e $laptop_mode ]; then
echo "0" > $laptop_mode
echo "$date laptop_mode=0" >> $LOG;
fi;

compact_memory=/proc/sys/vm/compact_memory
if [ -e $compact_memory ]; then
echo "1" > $compact_memory
echo "$date compact_memory=1" >> $LOG;
fi;

compact_unevictable_allowed=/proc/sys/vm/compact_unevictable_allowed
if [ -e $compact_unevictable_allowed ]; then
echo "1" > $compact_unevictable_allowed
echo "$date compact_unevictable_allowed=1" >> $LOG;
fi;

# page-cluster controls the number of pages up to which consecutive pages
# are read in from swap in a single attempt. This is the swap counterpart
# to page cache readahead.
# The mentioned consecutivity is not in terms of virtual/physical addresses,
# but consecutive on swap space - that means they were swapped out together.
# It is a logarithmic value - setting it to zero means "1 page", setting
# it to 1 means "2 pages", setting it to 2 means "4 pages", etc.
# Zero disables swap readahead completely.
# The default value is three (eight pages at a time).  There may be some
# small benefits in tuning this to a different value if your workload is
# swap-intensive.
# Lower values mean lower latencies for initial faults, but at the same time
# extra faults and I/O delays for following faults if they would have been part of
# that consecutive pages readahead would have brought in.
page_cluster=/proc/sys/vm/page-cluster
if [ -e $page_cluster ]; then
echo "0" > $page_cluster
echo "$date page_cluster=0" >> $LOG;
fi;

# vm.dirty_expire_centisecs is how long something can be in cache
# before it needs to be written.
# When the pdflush/flush/kdmflush processes kick in they will
# check to see how old a dirty page is, and if it’s older than this value it’ll
# be written asynchronously to disk. Since holding a dirty page in memory is
# unsafe this is also a safeguard against data loss.
dirty_expire_centisecs=/proc/sys/vm/dirty_expire_centisecs
if [ -e $dirty_expire_centisecs ]; then
echo "300" > $dirty_expire_centisecs
echo "$date dirty_expire_centisecs=300" >> $LOG;
fi;

# vm.dirty_writeback_centisecs is how often the pdflush/flush/kdmflush processes wake up
# and check to see if work needs to be done.
dirty_writeback_centisecs=/proc/sys/vm/dirty_writeback_centisecs
if [ -e $dirty_writeback_centisecs ]; then
echo "800" > $dirty_writeback_centisecs
echo "$date dirty_writeback_centisecs=800" >> $LOG;
fi;

# vm.dirty_background_ratio is the percentage of system memory(RAM)
# that can be filled with “dirty” pages — memory pages that
# still need to be written to disk — before the pdflush/flush/kdmflush
# background processes kick in to write it to disk.
# It can be 50% or less of dirtyRatio
# If ( dirty_background_ratio >= dirty_ratio ) {
# dirty_background_ratio = dirty_ratio / 2
dirty_background_ratio=/proc/sys/vm/dirty_background_ratio
if [ -e $dirty_background_ratio ]; then
echo "10" > $dirty_background_ratio
echo "$date dirty_background_ratio=10" >> $LOG;
fi;

# vm.dirty_ratio is the absolute maximum amount of system memory
# that can be filled with dirty pages before everything must get committed to disk.
# When the system gets to this point all new I/O blocks until dirty pages
# have been written to disk. This is often the source of long I/O pauses,
# but is a safeguard against too much data being cached unsafely in memory.
dirty_ratio=/proc/sys/vm/dirty_ratio
if [ -e $dirty_ratio ]; then
echo "35" > $dirty_ratio
echo "$date dirty_ratio=35" >> $LOG;
fi;

echo "$date Balanced virtual memory tweaks activated" >> $LOG;
}

virtualMemoryTweaksBattery() {
echo "$date Activating battery virtual memory tweaks..." >> $LOG;

sync

leases_enable=/proc/sys/fs/leases-enable
if [ -e $leases_enable ]; then
echo "1" > $leases_enable
echo "$date $leases_enable=1" >> $LOG;
fi;

# This file specifies the grace period (in seconds) that the kernel grants
# to a process holding a file lease after it has sent a signal to that process
# notifying it that another process is waiting to open the file.
# If the lease holder does not remove or downgrade the lease within this grace period,
# the kernel forcibly breaks the lease.

lease_break_time=/proc/sys/fs/lease-break-time
if [ -e $lease_break_time ]; then
echo "10" > $lease_break_time
echo "$date $lease_break_time=10" >> $LOG;
fi;

# dnotify is a signal used to notify a process about file/directory changes.
dir_notify_enable=/proc/sys/fs/dir-notify-enable
if [ -e $dir_notify_enable ]; then
echo "0" > $dir_notify_enable
echo "$date $dir_notify_enable=0" >> $LOG;
fi;

echo "$date File system parameters are updated" >> $LOG;

enable_process_reclaim=/sys/module/process_reclaim/parameters/enable_process_reclaim
if [ -e $enable_process_reclaim ]; then
echo "0" > $enable_process_reclaim
echo "$date Reclaiming pages of inactive tasks disabled" >> $LOG;
fi;

# This parameter tells how much of physical RAM to take when swap is full
overcommit_ratio=/proc/sys/vm/overcommit_ratio
if [ -e overcommit_ratio ]; then
echo "0" > $overcommit_ratio
echo "$date overcommit_ratio=0" >> $LOG;
fi;

oom_dump_tasks=/proc/sys/vm/oom_dump_tasks
if [ -e $oom_dump_tasks ]; then
echo "0" > $oom_dump_tasks
echo "$date OOM dump tasks are disabled" >> $LOG;
fi;

vfs_cache_pressure=/proc/sys/vm/vfs_cache_pressure
if [ -e $vfs_cache_pressure ]; then
echo "40" > $vfs_cache_pressure
echo "$date vfs_cache_pressure=40" >> $LOG;
fi;

laptop_mode=/proc/sys/vm/laptop_mode
if [ -e $laptop_mode ]; then
echo "0" > $laptop_mode
echo "$date laptop_mode=0" >> $LOG;
fi;

compact_memory=/proc/sys/vm/compact_memory
if [ -e $compact_memory ]; then
echo "1" > $compact_memory
echo "$date compact_memory=1" >> $LOG;
fi;

compact_unevictable_allowed=/proc/sys/vm/compact_unevictable_allowed
if [ -e $compact_unevictable_allowed ]; then
echo "1" > $compact_unevictable_allowed
echo "$date compact_unevictable_allowed=1" >> $LOG;
fi;

# page-cluster controls the number of pages up to which consecutive pages
# are read in from swap in a single attempt. This is the swap counterpart
# to page cache readahead.
# The mentioned consecutivity is not in terms of virtual/physical addresses,
# but consecutive on swap space - that means they were swapped out together.
# It is a logarithmic value - setting it to zero means "1 page", setting
# it to 1 means "2 pages", setting it to 2 means "4 pages", etc.
# Zero disables swap readahead completely.
# The default value is three (eight pages at a time).  There may be some
# small benefits in tuning this to a different value if your workload is
# swap-intensive.
# Lower values mean lower latencies for initial faults, but at the same time
# extra faults and I/O delays for following faults if they would have been part of
# that consecutive pages readahead would have brought in.
page_cluster=/proc/sys/vm/page-cluster
if [ -e $page_cluster ]; then
echo "0" > $page_cluster
echo "$date page_cluster=0" >> $LOG;
fi;

# vm.dirty_expire_centisecs is how long something can be in cache
# before it needs to be written.
# When the pdflush/flush/kdmflush processes kick in they will
# check to see how old a dirty page is, and if it’s older than this value it’ll
# be written asynchronously to disk. Since holding a dirty page in memory is
# unsafe this is also a safeguard against data loss.
dirty_expire_centisecs=/proc/sys/vm/dirty_expire_centisecs
if [ -e $dirty_expire_centisecs ]; then
echo "500" > $dirty_expire_centisecs
echo "$date dirty_expire_centisecs=500" >> $LOG;
fi;

# vm.dirty_writeback_centisecs is how often the pdflush/flush/kdmflush processes wake up
# and check to see if work needs to be done.
dirty_writeback_centisecs=/proc/sys/vm/dirty_writeback_centisecs
if [ -e $dirty_writeback_centisecs ]; then
echo "1000" > $dirty_writeback_centisecs
echo "$date dirty_writeback_centisecs=1000" >> $LOG;
fi;

# vm.dirty_background_ratio is the percentage of system memory(RAM)
# that can be filled with “dirty” pages — memory pages that
# still need to be written to disk — before the pdflush/flush/kdmflush
# background processes kick in to write it to disk.
# It can be 50% or less of dirtyRatio
# If ( dirty_background_ratio >= dirty_ratio ) {
# dirty_background_ratio = dirty_ratio / 2
dirty_background_ratio=/proc/sys/vm/dirty_background_ratio
if [ -e $dirty_background_ratio ]; then
echo "5" > $dirty_background_ratio
echo "$date dirty_background_ratio=5" >> $LOG;
fi;

# vm.dirty_ratio is the absolute maximum amount of system memory
# that can be filled with dirty pages before everything must get committed to disk.
# When the system gets to this point all new I/O blocks until dirty pages
# have been written to disk. This is often the source of long I/O pauses,
# but is a safeguard against too much data being cached unsafely in memory.
dirty_ratio=/proc/sys/vm/dirty_ratio
if [ -e $dirty_ratio ]; then
echo "20" > $dirty_ratio
echo "$date dirty_ratio=20" >> $LOG;
fi;

echo "$date Battery virtual memory tweaks activated" >> $LOG;
}

virtualMemoryTweaksPerformance() {
echo "$date Activating performance virtual memory tweaks..." >> $LOG;

sync

leases_enable=/proc/sys/fs/leases-enable
if [ -e $leases_enable ]; then
echo "1" > $leases_enable
echo "$date $leases_enable=1" >> $LOG;
fi;

# This file specifies the grace period (in seconds) that the kernel grants
# to a process holding a file lease after it has sent a signal to that process
# notifying it that another process is waiting to open the file.
# If the lease holder does not remove or downgrade the lease within this grace period,
# the kernel forcibly breaks the lease.

lease_break_time=/proc/sys/fs/lease-break-time
if [ -e $lease_break_time ]; then
echo "10" > $lease_break_time
echo "$date $lease_break_time=10" >> $LOG;
fi;

# dnotify is a signal used to notify a process about file/directory changes.
dir_notify_enable=/proc/sys/fs/dir-notify-enable
if [ -e $dir_notify_enable ]; then
echo "0" > $dir_notify_enable
echo "$date $dir_notify_enable=0" >> $LOG;
fi;

echo "$date File system parameters are updated" >> $LOG;

enable_process_reclaim=/sys/module/process_reclaim/parameters/enable_process_reclaim
if [ -e $enable_process_reclaim ]; then
echo "0" > $enable_process_reclaim
echo "$date Reclaiming pages of inactive tasks disabled" >> $LOG;
fi;

# This parameter tells how much of physical RAM to take when swap is full
overcommit_ratio=/proc/sys/vm/overcommit_ratio
if [ -e overcommit_ratio ]; then
echo "0" > $overcommit_ratio
echo "$date overcommit_ratio=0" >> $LOG;
fi;

oom_dump_tasks=/proc/sys/vm/oom_dump_tasks
if [ -e $oom_dump_tasks ]; then
echo "0" > $oom_dump_tasks
echo "$date OOM dump tasks are disabled" >> $LOG;
fi;

vfs_cache_pressure=/proc/sys/vm/vfs_cache_pressure
if [ -e $vfs_cache_pressure ]; then
echo "100" > $vfs_cache_pressure
echo "$date vfs_cache_pressure=100" >> $LOG;
fi;

laptop_mode=/proc/sys/vm/laptop_mode
if [ -e $laptop_mode ]; then
echo "0" > $laptop_mode
echo "$date laptop_mode=0" >> $LOG;
fi;

compact_memory=/proc/sys/vm/compact_memory
if [ -e $compact_memory ]; then
echo "1" > $compact_memory
echo "$date compact_memory=1" >> $LOG;
fi;

compact_unevictable_allowed=/proc/sys/vm/compact_unevictable_allowed
if [ -e $compact_unevictable_allowed ]; then
echo "1" > $compact_unevictable_allowed
echo "$date laptop_mode=1" >> $LOG;
fi;

# page-cluster controls the number of pages up to which consecutive pages
# are read in from swap in a single attempt. This is the swap counterpart
# to page cache readahead.
# The mentioned consecutivity is not in terms of virtual/physical addresses,
# but consecutive on swap space - that means they were swapped out together.
# It is a logarithmic value - setting it to zero means "1 page", setting
# it to 1 means "2 pages", setting it to 2 means "4 pages", etc.
# Zero disables swap readahead completely.
# The default value is three (eight pages at a time).  There may be some
# small benefits in tuning this to a different value if your workload is
# swap-intensive.
# Lower values mean lower latencies for initial faults, but at the same time
# extra faults and I/O delays for following faults if they would have been part of
# that consecutive pages readahead would have brought in.
page_cluster=/proc/sys/vm/page-cluster
if [ -e $page_cluster ]; then
echo "0" > $page_cluster
echo "$date page_cluster=0" >> $LOG;
fi;

# vm.dirty_expire_centisecs is how long something can be in cache
# before it needs to be written.
# When the pdflush/flush/kdmflush processes kick in they will
# check to see how old a dirty page is, and if it’s older than this value it’ll
# be written asynchronously to disk. Since holding a dirty page in memory is
# unsafe this is also a safeguard against data loss.
dirty_expire_centisecs=/proc/sys/vm/dirty_expire_centisecs
if [ -e $dirty_expire_centisecs ]; then
echo "300" > $dirty_expire_centisecs
echo "$date dirty_expire_centisecs=300" >> $LOG;
fi;

# vm.dirty_writeback_centisecs is how often the pdflush/flush/kdmflush processes wake up
# and check to see if work needs to be done.
dirty_writeback_centisecs=/proc/sys/vm/dirty_writeback_centisecs
if [ -e $dirty_writeback_centisecs ]; then
echo "700" > $dirty_writeback_centisecs
echo "$date dirty_writeback_centisecs=700" >> $LOG;
fi;

# vm.dirty_background_ratio is the percentage of system memory(RAM)
# that can be filled with “dirty” pages — memory pages that
# still need to be written to disk — before the pdflush/flush/kdmflush
# background processes kick in to write it to disk.
# It can be 50% or less of dirtyRatio
# If ( dirty_background_ratio >= dirty_ratio ) {
# dirty_background_ratio = dirty_ratio / 2
dirty_background_ratio=/proc/sys/vm/dirty_background_ratio
if [ -e $dirty_background_ratio ]; then
echo "5" > $dirty_background_ratio
echo "$date dirty_background_ratio=10" >> $LOG;
fi;

# vm.dirty_ratio is the absolute maximum amount of system memory
# that can be filled with dirty pages before everything must get committed to disk.
# When the system gets to this point all new I/O blocks until dirty pages
# have been written to disk. This is often the source of long I/O pauses,
# but is a safeguard against too much data being cached unsafely in memory.
dirty_ratio=/proc/sys/vm/dirty_ratio
if [ -e $dirty_ratio ]; then
echo "20" > $dirty_ratio
echo "$date dirty_ratio=20" >> $LOG;
fi;

echo "$date Performance virtual memory tweaks activated" >> $LOG;
}

#
# Profile presets
#
setDefaultProfile() {
	write $USER_PROFILE/battery_improvements "1"
		
	# CPU section
	write $USER_PROFILE/cpu_optimization "2"
	write $USER_PROFILE/gov_tuner "2"

	# Entropy section
	write $USER_PROFILE/entropy "0"

	# GPU section
	write $USER_PROFILE/gpu_optimizer "2"
	write $USER_PROFILE/optimize_buffers "0"
	write $USER_PROFILE/render_opengles_using_gpu "0"
	write $USER_PROFILE/use_opengl_skia "0"

	# I/O tweaks section
	write $USER_PROFILE/disable_io_stats "1"
	write $USER_PROFILE/io_blocks_optimization "2"
	write $USER_PROFILE/io_extended_queue "0"
	write $USER_PROFILE/partition_remount "0"
	write $USER_PROFILE/scheduler_tuner "1"
	write $USER_PROFILE/sd_tweak "0"

	# LNET tweaks section
	write $USER_PROFILE/dns "0"
	write $USER_PROFILE/net_buffers "0"
	write $USER_PROFILE/net_speed_plus "0"
	write $USER_PROFILE/net_tcp "1"
	write $USER_PROFILE/optimize_ril "1"

	# Other
	write $USER_PROFILE/disable_debugging "1"
	write $USER_PROFILE/disable_kernel_panic "1"

	# RAM manager section
	write $USER_PROFILE/ram_manager "2"
	write $USER_PROFILE/disable_multitasking_limitations "0"
	write $USER_PROFILE/low_ram_flag "0"
	write $USER_PROFILE/oom_killer "0"
	write $USER_PROFILE/swappiness "1"
	write $USER_PROFILE/virtual_memory "2"
	write $USER_PROFILE/heap_optimization "1"
	write $USER_PROFILE/zram_optimization "0"
}
 
setPowerSavingProfile() {
	write $USER_PROFILE/battery_improvements "1"
		
	# CPU section
	write $USER_PROFILE/cpu_optimization "1"
	write $USER_PROFILE/gov_tuner "1"

	# Entropy section
	write $USER_PROFILE/entropy "0"

	# GPU section
	write $USER_PROFILE/gpu_optimizer "1"
	write $USER_PROFILE/optimize_buffers "0"
	write $USER_PROFILE/render_opengles_using_gpu "0"
	write $USER_PROFILE/use_opengl_skia "0"

	# I/O tweaks section
	write $USER_PROFILE/disable_io_stats "1"
	write $USER_PROFILE/io_blocks_optimization "1"
	write $USER_PROFILE/io_extended_queue "0"
	write $USER_PROFILE/partition_remount "0"
	write $USER_PROFILE/scheduler_tuner "1"
	write $USER_PROFILE/sd_tweak "0"

	# LNET tweaks section
	write $USER_PROFILE/dns "0"
	write $USER_PROFILE/net_buffers "0"
	write $USER_PROFILE/net_speed_plus "0"
	write $USER_PROFILE/net_tcp "1"
	write $USER_PROFILE/optimize_ril "1"

	# Other
	write $USER_PROFILE/disable_debugging "1"
	write $USER_PROFILE/disable_kernel_panic "1"

	# RAM manager section
	write $USER_PROFILE/ram_manager "2"
	write $USER_PROFILE/disable_multitasking_limitations "0"
	write $USER_PROFILE/low_ram_flag "0"
	write $USER_PROFILE/oom_killer "0"
	write $USER_PROFILE/swappiness "1"
	write $USER_PROFILE/virtual_memory "1"
	write $USER_PROFILE/heap_optimization "1"
	write $USER_PROFILE/zram_optimization "0"
}

setBalancedProfile() {
	write $USER_PROFILE/battery_improvements "1"
		
	# CPU section
	write $USER_PROFILE/cpu_optimization "2"
	write $USER_PROFILE/gov_tuner "2"

	# Entropy section
	write $USER_PROFILE/entropy "0"

	# GPU section
	write $USER_PROFILE/gpu_optimizer "2"
	write $USER_PROFILE/optimize_buffers "0"
	write $USER_PROFILE/render_opengles_using_gpu "0"
	write $USER_PROFILE/use_opengl_skia "0"

	# I/O tweaks section
	write $USER_PROFILE/disable_io_stats "1"
	write $USER_PROFILE/io_blocks_optimization "2"
	write $USER_PROFILE/io_extended_queue "0"
	write $USER_PROFILE/partition_remount "0"
	write $USER_PROFILE/scheduler_tuner "1"
	write $USER_PROFILE/sd_tweak "0"

	# LNET tweaks section
	write $USER_PROFILE/dns "0"
	write $USER_PROFILE/net_buffers "0"
	write $USER_PROFILE/net_speed_plus "0"
	write $USER_PROFILE/net_tcp "1"
	write $USER_PROFILE/optimize_ril "1"

	# Other
	write $USER_PROFILE/disable_debugging "1"
	write $USER_PROFILE/disable_kernel_panic "1"

	# RAM manager section
	write $USER_PROFILE/ram_manager "2"
	write $USER_PROFILE/disable_multitasking_limitations "1"
	write $USER_PROFILE/low_ram_flag "0"
	write $USER_PROFILE/oom_killer "0"
	write $USER_PROFILE/swappiness "2"
	write $USER_PROFILE/virtual_memory "2"
	write $USER_PROFILE/heap_optimization "1"
	write $USER_PROFILE/zram_optimization "0"
}

setPerformanceProfile() {
	write $USER_PROFILE/battery_improvements "1"
		
	# CPU section
	write $USER_PROFILE/cpu_optimization "3"
	write $USER_PROFILE/gov_tuner "3"

	# Entropy section
	write $USER_PROFILE/entropy "2"

	# GPU section
	write $USER_PROFILE/gpu_optimizer "3"
	write $USER_PROFILE/optimize_buffers "0"
	write $USER_PROFILE/render_opengles_using_gpu "0"
	write $USER_PROFILE/use_opengl_skia "0"

	# I/O tweaks section
	write $USER_PROFILE/disable_io_stats "1"
	write $USER_PROFILE/io_blocks_optimization "3"
	write $USER_PROFILE/io_extended_queue "1"
	write $USER_PROFILE/partition_remount "0"
	write $USER_PROFILE/scheduler_tuner "1"
	write $USER_PROFILE/sd_tweak "0"

	# LNET tweaks section
	write $USER_PROFILE/dns "0"
	write $USER_PROFILE/net_buffers "0"
	write $USER_PROFILE/net_speed_plus "1"
	write $USER_PROFILE/net_tcp "1"
	write $USER_PROFILE/optimize_ril "1"

	# Other
	write $USER_PROFILE/disable_debugging "1"
	write $USER_PROFILE/disable_kernel_panic "1"

	# RAM manager section
	write $USER_PROFILE/ram_manager "3"
	write $USER_PROFILE/disable_multitasking_limitations "1"
	write $USER_PROFILE/low_ram_flag "0"
	write $USER_PROFILE/oom_killer "0"
	write $USER_PROFILE/swappiness "1"
	write $USER_PROFILE/virtual_memory "3"
	write $USER_PROFILE/heap_optimization "1"
	write $USER_PROFILE/zram_optimization "0"
}

sendToLog "$date Starting L Speed";

# Read current profile
currentProfile=$(cat $PROFILE 2> /dev/null);

if [ "$currentProfile" == "-1" ]; then
	profile="user defined";
	
elif [ "$currentProfile" == "0" ]; then
	profile="default";
	setDefaultProfile;
	
elif [ "$currentProfile" == "1" ]; then
	profile="power saving";
	setPowerSavingProfile;

elif [ "$currentProfile" == "2" ]; then
	profile="balanced";
	setBalancedProfile;
	
elif [ "$currentProfile" == "3" ]; then
	profile="performance";
	setPerformanceProfile;
else
	profile="default";
	setDefaultProfile;
fi


# Wait for boot completed
attempts=10
while [ "$attempts" -gt 0 ] && [ "$(getprop sys.boot_completed)" != "1" ]; do
   attempts=$((attempts-1));
   sendToLog "$date Waiting for boot_completed";
   sleep 10
done

sendToLog "$date Applying $profile profile";

if [ `cat $USER_PROFILE/battery_improvements` -eq 1 ]; then
	batteryImprovements;
fi

#
# CPU tuner section
#
if [ `cat $USER_PROFILE/cpu_optimization` -eq 1 ]; then
	cpuOptimizationBattery;
elif [ `cat $USER_PROFILE/cpu_optimization` -eq 2 ]; then
	cpuOptimizationBalanced;
elif [ `cat $USER_PROFILE/cpu_optimization` -eq 3 ]; then
	cpuOptimizationPerformance;
fi

#if [ `cat $USER_PROFILE/gov_tuner` -eq 1 ]; then
	# soon;
#elif [ `cat $USER_PROFILE/gov_tuner` -eq 2 ]; then
#	# soon;
#elif [ `cat $USER_PROFILE/gov_tuner` -eq 3 ]; then
#	# soon;
#fi
	
#
# Entropy section
#
if [ `cat $USER_PROFILE/entropy` -eq 1 ]; then
	entropyLight;
elif [ `cat $USER_PROFILE/entropy` -eq 2 ]; then
	entropyEnlarger;
elif [ `cat $USER_PROFILE/entropy` -eq 3 ]; then
	entropyModerate;
elif [ `cat $USER_PROFILE/entropy` -eq 4 ]; then
	entropyAggressive;
fi

#
# GPU section
#
if [ `cat $USER_PROFILE/gpu_optimizer` -eq 1 ]; then
	gpuOptimizerPowerSaving;
elif [ `cat $USER_PROFILE/gpu_optimizer` -eq 2 ]; then
	gpuOptimizerBalanced;
elif [ `cat $USER_PROFILE/gpu_optimizer` -eq 3 ]; then
	gpuOptimizerPerformance;
fi
	
if [ `cat $USER_PROFILE/optimize_buffers` -eq 1 ]; then
	optimizeBuffers;
fi

if [ `cat $USER_PROFILE/render_opengles_using_gpu` -eq 1 ]; then
	renderOpenglesUsingGpu;
fi

if [ `cat $USER_PROFILE/use_opengl_skia` -eq 1 ]; then
	useOpenglSkia;
fi

#
# I/O tweaks section
#
if [ `cat $USER_PROFILE/disable_io_stats` -eq 1 ]; then
	disableIoStats;
fi

if [ `cat $USER_PROFILE/io_blocks_optimization` -eq 1 ]; then
	ioBlocksOptimizationPowerSaving;
elif [ `cat $USER_PROFILE/io_blocks_optimization` -eq 2 ]; then
	ioBlocksOptimizationBalanced;
elif [ `cat $USER_PROFILE/io_blocks_optimization` -eq 3 ]; then
	ioBlocksOptimizationPerformance;
fi

if [ `cat $USER_PROFILE/io_extended_queue` -eq 1 ]; then
	ioExtendedQueue;
fi

if [ `cat $USER_PROFILE/partition_remount` -eq 1 ]; then
	partitionRemount;
fi

#if [ `cat $USER_PROFILE/scheduler_tuner` -eq 1 ]; then
#	partitionRemount;
#fi

#if [ `cat $USER_PROFILE/sd_tweak` -eq 1 ]; then
#	partitionRemount;
#fi

#	
# LNET tweaks section
#
if [ `cat $USER_PROFILE/dns` -eq 1 ]; then
	dnsOptimizationGooglePublic;
elif [ `cat $USER_PROFILE/dns` -eq 2 ]; then
	dnsOptimizationzCloudFlare;
fi

if [ `cat $USER_PROFILE/net_buffers` -eq 1 ]; then
	netBuffersSmall;
elif [ `cat $USER_PROFILE/net_buffers` -eq 2 ]; then
	netBuffersBig;
fi

if [ `cat $USER_PROFILE/net_speed_plus` -eq 1 ]; then
	netSpeedPlus;
fi

if [ `cat $USER_PROFILE/net_tcp` -eq 1 ]; then
	netTcpTweaks;
fi

if [ `cat $USER_PROFILE/optimize_ril` -eq 1 ]; then
	rilTweaks;
fi

#	
# Other
#
if [ `cat $USER_PROFILE/disable_debugging` -eq 1 ]; then
	disableDebugging;
fi

if [ `cat $USER_PROFILE/disable_kernel_panic` -eq 1 ]; then
	disableKernelPanic;
fi

#	
# RAM manager section
#
if [ `$USER_PROFILE/ram_manager` -eq 1 ]; then
	ramManagerMultitasking;
elif [ `cat $USER_PROFILE/ram_manager` -eq 2 ]; then
	ramManagerBalanced;
elif [ `cat $USER_PROFILE/ram_manager` -eq 3 ]; then
	ramManagerGaming;
fi

if [ `cat $USER_PROFILE/disable_multitasking_limitations` -eq 1 ]; then
	disableMultitaskingLimitations;
fi

if [ `cat $USER_PROFILE/low_ram_flag` -eq 0 ]; then
	lowRamFlagDisabled;
elif [ `cat $USER_PROFILE/low_ram_flag` -eq 1 ]; then
	lowRamFlagEnabled;
fi

if [ `cat $USER_PROFILE/oom_killer` -eq 0 ]; then
	oomKillerDisabled;
elif [ `cat $USER_PROFILE/oom_killer` -eq 1 ]; then
	oomKillerEnabled;
fi

if [ `cat $USER_PROFILE/swappiness` -eq 1 ]; then
	swappinessTendency1;
elif [ `cat $USER_PROFILE/swappiness` -eq 2 ]; then
	swappinessTendency10;
elif [ `cat $USER_PROFILE/swappiness` -eq 3 ]; then
	swappinessTendency25;
elif [ `cat $USER_PROFILE/swappiness` -eq 4 ]; then
	swappinessTendency50;
elif [ `cat $USER_PROFILE/swappiness` -eq 5 ]; then
	swappinessTendency75;
elif [ `cat $USER_PROFILE/swappiness` -eq 6 ]; then
	swappinessTendency100;
fi

if [ `cat $USER_PROFILE/virtual_memory` -eq 1 ]; then
	virtualMemoryTweaksBattery;
elif [ `cat $USER_PROFILE/virtual_memory` -eq 2 ]; then
	virtualMemoryTweaksBalanced;
elif [ `cat $USER_PROFILE/virtual_memory` -eq 3 ]; then
	virtualMemoryTweaksPerformance;
fi

#if [ `cat $USER_PROFILE/heap_optimization` -eq 1 ]; then
#	disableMultitaskingLimitations;
#fi

#if [ `cat $USER_PROFILE/zram_optimization` -eq 1 ]; then
#	disableMultitaskingLimitations;
#fi

sendToLog "$date Successfully applied $profile profile";

exit 0
