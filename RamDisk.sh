#!/bin/sh
#
# *************************************************************************
# *************************************************************************
# * RamDisk.sh - RamDisk - a HFS+ Drive/Disk Creator In RAM.
# * Copyright © 2020 Erik T Ashfolk (<atErïk＠ÖυťĹöōķ·ċōm;atErïk＠AśhFölķ·ćōm> Do Not Copy, 
# *       Type in English/basic-latin char. No Soliciting Permitted). All rights reserved.
# * Written initially on 2020-06-23 by Erik T Ashfolk.
# * Released with below Licenses+Restrictions+Permissions:
# *  (*) Do Not Use My/Our Contribution(s) To Kill/Harm/Violate(or Steal-from)(Any) Human/Community,Earth,etc.
# *  (*) GNU General Public License v3 (GPL v3) https://www.GNU.org/licenses/gpl-3.0.en.html 
# * 
# * RamDisk.sh - RamDisk - v0.52
# * It creates a ramdisk by using macOSX tools: diskutil, hdiutil, etc
# * Use "Eject" in Finder, to erase it. (Warning: All Data Will Be Lost).
# *************************************************************************
# *************************************************************************
# 
# Notes:  Primary command:
# diskutil erasevolume HFS+ 'RAM Disk' `hdiutil attach -nomount ram://NumberOfDiskSectors`
# diskutil erasevolume HFS+ 'RAM Disk' `hdiutil attach -nomount ram://8388608` 
#
# *************************************************************************
# *************************************************************************

showUsage=0;

freeRAM="`./ShowMemory.sh | /usr/bin/grep 'Free (Physical/RAM)'`";
# freeRAM="`/SPECIFY-DIRECTORIES-PATH-TO-THE-FILE/ShowMemory.sh | /usr/bin/grep 'Free (Physical/RAM)'`";
freeRAM="${freeRAM#*\:\ }";

version="v0.52";

if [ ! -z $1 ] && [ ! -z $2 ] ; then
	# Getting user-specified parameter number 1 which is 1st-parameter in commandline
	uP1fullLength=${#1};                      # example: "100MB" has fullLength = 5
	sizeDigitsLength=$(( $uP1fullLength - 2 )); # example: 5 - 2 = 3
	diskSize=${1:0:${sizeDigitsLength}};      # example: "100MB" - "__" = "100"
	multiplierLetters="${1:$sizeDigitsLength}"; # example: "100MB" - skip digits "100" = "MB"
	diskSizeMultiplier=1;
	case "$multiplierLetters" in
		('KB'|'kB') diskSizeMultiplier=1024; ;;
		('MB')      diskSizeMultiplier=1048576; ;;
		('GB'|'gB') diskSizeMultiplier=1073741824; ;;
	esac;
	if [ "$diskSizeMultiplier" -eq "1" ]; then
		printf "\033[1mRamDisk\033[0m %s (\033[1mError\033[0m: please use 2-letters at-end of disk size: \"\033[1mKB\033[0m\"(KiloBytes) or \"\033[1mMB\033[0m\"(MegaBytes) or \"\033[1mGB\033[0m\"(GigaBytes).)\n" $version;
		showUsage=1;
	else
		diskSizeBytes=$(( $diskSize * $diskSizeMultiplier ));
		if [ ! -z $3 ] && [ "$3" == "--force" ]; then
			freeMem="9223372036854775807";
		else
			freeMem="$freeRAM";
		fi;
		if [ "$freeMem" -ge "$(( $diskSizeBytes / 1048576 ))" ]; then
			# each sector has 512 bytes . "hdiutil" command needs sector
			diskSectors=$(( $diskSizeBytes / 512 ));
			
			# removing begin/end double-quote symbol if/when exists in "$2"
			diskName="${2%\"}" ;	# remove ending "
			diskName="'${diskName#\"}'" ;	# remove begining "
			printf "\033[1mRamDisk\033[0m %s ( Please wait ... beginning to create a disk ... )\n" $version;
			# create a drive/disk in RAM, and format it with HFS+ partitioning scheme:
			/usr/sbin/diskutil erasevolume HFS+ $diskName `/usr/bin/hdiutil attach -nomount ram://$diskSectors` && { 
				printf "\033[1mRamDisk\033[0m %s (RamDisk was \033[1mcreated successfully\033[0m)\n" $version;
				printf " (Note: when \033[1mEJECT\033[0m is pressed in \033[1mFinder\033[0m, then Drive/Disk is Erased & ALL-DATA is \033[1mErased+Lost\033[0m)\n";
				printf " diskutil list\n";
				# showing user a list of all disks/drives
				/usr/sbin/diskutil list ;
			} || {
				printf "\033[1mRamDisk\033[0m %s (\033[1mError\033[0m: Could-Not Create RamDisk in RAM)\n" $version;
			};
			unset diskSectors diskName;
		else
			printf "\033[1mRamDisk\033[0m %s (\033[1mError\033[0m: please specify smaller size for RamDisk/RamDrive)\n" $version;
			showUsage=1;
		fi;
		unset diskSizeBytes freeMem;
	fi;
	unset uP1fullLength sizeDigitsLength diskSize multiplierLetters diskSizeMultiplier;
else
	showUsage=1;
fi;

if [ "$showUsage" -eq "1" ]; then
	printf "\033[1mRamDisk\033[0m %s ( Current Free RAM (MBytes): \033[1m$freeRAM\033[0m )\n" $version;
	printf " Released with below \033[1;4mLicenses+Restrictions+Permissions\033[0m:\n";
	printf " \033[1m*\033[0m GNU General Public License v3 (GPL v3) https://www.GNU.org/licenses/gpl-3.0.en.html\n";
	printf " \033[1m*\033[0m Do Not Use This To Kill/Harm/Violate (or Steal-from)(Any) Human/Community,Earth,etc.\n";
	printf " \033[1m*\033[0m Copyright © 2020 Erik T Ashfolk (<at\105rïk＠ÖυťĹöōķ·ċōm\033[1m;\033[0mat\105rïk＠\101śh\106ölķ·ćōm> Do Not Copy, Type in English/basic-latin char. No Soliciting Permitted). All rights reserved.\n";
	printf " Usage  :  RamDisk  Size_in_\033[1mGB\033[0mor\033[1mMB\033[0mor\033[1mKB\033[0m  \"Name_for-this_HFS+_Drive_in_RAM\"\n";
	printf " example:  RamDisk  1024\033[1mKB\033[0m  \"My Tiny RamDrive-1\"\n";
	printf "           RamDisk  650\033[1mMB\033[0m  \"My RamDrive-2\"\n";
	printf "           RamDisk  1\033[1mGB\033[0m  \"My Big RamDrive-3\"\n";
	printf "           RamDisk  1\033[1mGB\033[0m  \"My Big RamDrive-3\"\n";
	printf "           RamDisk  1\033[1mGB\033[0m  \"My Big RamDrive-4\"  --force\n";
	printf " Note: when \033[1mEJECT\033[0m is pressed in \033[1mFinder\033[0m, then Drive/Disk is Erased & ALL-DATA is \033[1mErased+Lost\033[0m.\n";
	printf " Note: you may use \033[1m--force\033[0m at-end, to try to create RamDrive by force, when \"FREE\" memory is not sufficient.\n";
fi;

unset freeRAM showUsage version;
