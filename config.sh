#!/bin/bash

#installType 1: unencrypted boot and root partition
#installType 2: unencrypted boot and encrypted root partition
#installType 3: unencrypted efi and encrypted root+boot partition
#installType 4: unencrypted efi, encrypted boot and seperate encrypted root partition
installType="1"

#target drive
drive="/dev/sda"

#if target drive is a nvme drive, change value to y
isNvme="n"

#luks password of the root drive (and the boot drive, if installType is 3)
drivePassword="qwerty"

#boot drive password
bootDrivePassword="qwerty"

#zoneinfo
zone="Europe/Berlin"

#keyboard layout
layout="en_US.UTF-8"

#root password
rootPassword="qwerty"

#username
userName="user"

#user password
userPassword="qwerty"

#device name
compName="ArtixBox"

#if computer won't be used with a GUI, change to n
desktop="y"

#install my custom DWM build, won't be installed if desktop is n
installDWM="y"

#install my custom ST build, won't be installed if desktop is n
installST="y"

#install my custom config files and a few scripts I use regularly
installScripts="y"

#drivers and additional software, uncomment lines to add them

#NVIDIA video drivers
#drivers="$drivers nvidia-dkms nvidia-settings"

#Intel video drivers
#drivers="$drivers mesa"

#VirtualBox drivers
#drivers="$drivers virtualbox-guest-utils"

#additional software
apps="ranger atool w3m ncmpcpp btop neofetch gvim bash-completion"

#desktop apps won't be installed, if desktop is n
desktopApps="dmenu picom nitrogen wmname ttf-dejavu"



### DON'T EDIT THE FOLLOWING LINES ###


driveHldr="$drive"

if [ $isNvme = "y" ]
then
    driveHldr="$drive"p
fi

if [ $installType -lt 3 ]
then
    efiDrive="/dev/null"
    bootDrive="$driveHldr"1
    rootDrive="$driveHldr"2
elif [ $installType = 3 ]
then 
    efiDrive="$driveHldr"1
    bootDrive="/dev/null"
    rootDrive="$driveHldr"2
else
    efiDrive="$driveHldr"1
    bootDrive="$driveHldr"2
    rootDrive="$driveHldr"3
fi

mountBootDrive="$bootDrive"
if [ $installType == "4" ]
then
    mountBootDrive="/dev/mapper/boot"
fi

mountRootDrive="$rootDrive"
if [ $installType != 1 ]
then
    mountRootDrive="/dev/mapper/root"
fi

if [ $desktop == "y" ]
then
    desktopPackages="xorg xorg-xrandr xorg-xinit libxinerama pipewire pipewire-alsa pipewire-pulse pipewire-jack wireplumber"
else
    desktopPackages=""
	desktopApps=""
    installDWM="n"
    installST="n"
fi

debug="n"

if [ $debug == "y" ]
then
    echo -e " EFI Drive: $efiDrive \n Boot Drive: $bootDrive \n Root Drive: $rootDrive \n Boot Mount: $mountBootDrive \n Root Mount: $mountRootDrive \n Drivers: $drivers \n Desktop Packages: $desktopPackages \n Apps: $apps \n Desktop Apps: $desktopApps \n Install DWM: $installDWM \n Install ST: $installST"
fi
