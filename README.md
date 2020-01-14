<h1 align="center">L Speed magisk</h1>

<p align="center">
<a href="https://forum.xda-developers.com/apps/l-speed">
<img src="https://img.shields.io/badge/XDA-Thread-orange.svg?style=flat-square"></a> 

<a href="https://t.me/LSpeedDiscussion">
<img src="https://img.shields.io/badge/Telegram-Group-blue.svg?style=flat-square"></a> 

<a href="https://lspeed2016.wordpress.com">
<img src="https://img.shields.io/badge/L%20Speed-Blog-blue.svg?style=flat-square"></a>
</p>

<div align="center">
  <strong>The most advanced Android tweaker.
</div>

<div align="center">
  <h3>
    <a href="https://github.com/Paget96/lspeed_magisk">
      Source Code
    </a>
    <span> | </span>
    <a href="https://forum.xda-developers.com/apps/l-speed">
      XDA
    </a>
  </h3>
</div>

## Introduction
L Speed is a modification that combines tweaks inside an intuitive module who aims to improve kernel with optimal parameter changes for the widest range of devices.
It's goal is to improve overall performance, reduce significant lags, extend battery life and improve your experience on Android. Fully customizable module with prebuit manager.
It's very simple to use, everything is well explained in the manager it self, every option have a info button beside it.
The mod will and should work on any device that meets its minimum requirement.
You only need a rooted Android device with Magisk 19.x+ version..

<div align="center">
**Module with prebuilt manager**

<img src="https://github.com/Magisk-Modules-Repo/lspeed/blob/master/screenshots/1.png" width="192" height="317"/> <img src="https://github.com/Magisk-Modules-Repo/lspeed/blob/master/screenshots/2.png" width="192" height="317"/> <img src="https://github.com/Magisk-Modules-Repo/lspeed/blob/master/screenshots/3.png" width="192" height="317"/> <img src="https://github.com/Magisk-Modules-Repo/lspeed/blob/master/screenshots/4.png" width="192" height="317"/>
</div>

**Requirements:**
1. Root (Magisk 19.x +)

## Downloads
* For stable and beta versions, download link is below
- https://github.com/Magisk-Modules-Repo/lspeed

* For canary builds, download link is below
- https://github.com/Magisk-Modules-Repo/lspeed/archive/master.zip
- Canary builds are bleeding edge builds and can contain bugs. Be aware of it, you flash this on your own. Those builds contains the changes till the latest commit on GitHub.

After downloading canary build you just have to repack zip, extract, go into master folder and zip all the files inside.
Uninstalling current version is necessary. 
After everything is done, flash the zip.

Please provide L Speed logs located in:
/data/lspeed/logs

And magisk logs, located in:
/data/cache/magisk.log

## Bug report
- If you are one of the users with the issues on your device (such as bootloop, device freeze) please get Magisk canary (because of logs), 
test the problematic build and pass me L Speed and Magisk log, logcat will be also welcomed. 
You can pass them on any links from below (Telegram is recommended)


**Links:**
- [xda-thread](https://forum.xda-developers.com/apps/l-speed)
- [Reddit](https://www.reddit.com/r/LSpeedOptimizer/)
- [Facebook page](https://www.facebook.com/LSpeedAndroidOptimizer)
- [Facebook group](https://www.facebook.com/groups/169281933668021/?source_id=1503157226676471)
- [Blog](https://lspeed2016.wordpress.com)
- [Instagram](https://instagram.com/p/BxUcz0zlVUj/?igshid=1ib59rrsrjffl)
- [Telegram group](https://t.me/LSpeedDiscussion)
- [Telegram channel](https://t.me/LSpeedChannel)
- [Translate](https://forum.xda-developers.com/apps/l-speed/translating-help-translating-l-speed-t3587252)
- [Telegram **My projects** channel](https://t.me/paget96_projects_channel)

- [Check my developer account and other apps](https://play.google.com/store/apps/dev?id=6924549437581780390&hl=en)

If you want, you can support me over [Paypal donate](https://paypal.me/Paget96), to support my work.

## Changelog 
**v1.6.3**
- Improved UI flow
- Updated cpusets
- Updated cleaner
- Updated disable debugging
- App optimized and fixed issues

**V1.6.2**
- Fixed issues with freezing on some devices

**v1.6.1**
- Added junk and app cache cleaner
- Updated cpusets 
- Improved CPU detection for the devices with tweaked frequencies
- Improved detection of inverted clusters
- Added cpuset tweaks for 0-3 4-5 6-7 cpu configuration
- Fixed problem on devices with incompatible commands
- Removed ads from dialogs
- Improved L button optimization
- Slightly updated I/O optimization profiles
- Updated aggressive doze
- Code optimization and overall improvements

**v1.6**
- Updated magisk template (Starting with this version L Speed works just with Magisk 19.x+ versions)
- Updated CFQ and BFQ scheduler parameters (Set CFQ and BFQ schedulers to gorup tasks this will slightly improve it's effectivness. It's better than threat every as separated IO queue Disable low_latency on both, so we can get a bit bigger r/w speeds)
- Updated virtual memory tweaks, reduced diry pages flush time
- Improved manager installation
- Fixed issue with no busybox file
- Fixed issue with execution
- Added cpu_detect function
- Improved CPU detection on some devices(for one with no reguler scaling_avalilable_freqs file such as Exynos)
- Return just 0 to logical core if affected_cpu file don't exists
- Updated manger app, added code to remove old one and replace with new
- Separated cpuset from main script
- Fixed output for triple cluster devices
- Updated doze optimization
- Fixed some root issues
- Fixed hanging manager on splash logo
- Fixed issue with chosing animation duration
- Fixed adding L Speed app to doze ignore
- Fixed issue  with Secure settings fatal exception
- Fixed issues with aggressive doze
- Fixed issue with not sticking or not working disable when charging and disable motion detection
- Improved script code

**v1.5**
- Added force GPU rendering with brief explanation
- Added force 4x msaa with brief explanation
- Added GPU info
- Added advanced reboot menu
- Added selinux toggle
- min_free_kbytes reduced
- Disabled merges for all blocks
- Fixed typo in log output for fiops scheduler
- Improved compatibility of governor tuner
- Improved governor tuner detection of PRIME and BIG cpu cores
- Swapped governor parameters for BIG and PRIME cores
- Fixed detection of triple clustered devices
- Added governor tuner execution interval
- Added support for schedutilX
- Fixed some syntax errors
- Fixed issues with loading back a setup
- Main tweaks section renamed to misc
- Optimized app code

**v1.4**
- Improved Governor tuner (supported interactive and schedutil for now)
- Fixed some code related issues
- Fixed problem with no sticking options
- Updated Manager
- Improved mod installing and extracting of the files

**v1.3**
- Improved arch detection
- Updated virtual memory profiles
- Improved calculations
- Switched from unity to magisk template
- Improved L button optimization
- Fixed fstriming
- Fixed ram cleaning
- Fixed issues with applying some tweaks
- Fixed problem with root stuck after script execution
- Improved getting free ram before and after optimization
- Fixed some weird logging issues
- Improved agressive doze
- Added start aggressive doze on boot if enabled
- Fixed checking disable doze while chargin and disable device sensors
- Added some bootloop preventers
- Fixed issue with reverting settings
- Fixed issue with not sticking a profile
- Added custom busybox support
- Added busybox support for some options 
- Fixed issue with detecting memTotal
- Improved code for faster applying settings
- Improved speed
- Overall code fixes and improvements

**v1.2.4**
- Added window animation scale, transition animation scale, animator duration scale
- Fixed files permissions
- Updated IO Blocks profiles
- Improved calculations for Ram Manager (all profiles) (less aggressive)
- Disable I/O stats disabled by default on all profiles
- Updated explanation of disable I/O stats
- Updated heap optimization
- Updated Virtual memory tweaks (all profiles)
- Set rq_affinity only to 0 and 1, some kernels don't support aggressive
- Fixed up some mess for dirty caches, fixed up expire time and how often to flush
- Reduced percentage for max cache size before force to flush
- Updated logging

**v1.2.3**
- L Speed manager removed from /system, zip should install it as user app
- Established Scheduler tuner, support for deadline, anxiety, cfq, bfq, row, fiops, sio, sioplus, zen
- Fixed SD tweak
- Fixed syntax
- Code improvements

**v1.2.2**
- Prevent issues when $memTotal return weird output (including non-integer values, empty strings...),
in this case device acts like a 4GB RAM device
- Improved IO block optimization profiles, fixed some mess
- Updated min_free_kbytes and extra_free_kbytes calculation
- Fixed text print when installing module
- Removed some useless stuff from code
- Fixed some syntax errors
- Improved overall device performances and battery life

**v1.2.1**
- This version have everything disabled by default (if clean install)
- Run script in background when executing on boot
- Added boot completed check
- Wait 1min 30secs after boot to set up parameters
- Enabled adreno idler on balanced profile
- Updated read_aheads for blocks
- Updated net speed+
- Improved disable debugging
- Added ms to log timing
- Fixed issues with Optimize button in manager
- Updated busybox check
- Updated code with POSIX syntax fixes
- Improved code
- Enabled full debug for this build

**v1.1**
- Increased optimize time to a bit more than 24h
- Improved device optimization
- Added user defined indicator
- Improved chanigng profiles
- Updated virtual memory tweaks
- Updated IO block optimization
- Updated logging
