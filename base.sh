#!/bin/bash

source config.sh

echo "This script installs Artix GNU/Linux with Runit. Please edit config.sh according to your drive setup and preferences."
read -p "Do you want to continue (y/N)? " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    [[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1
fi
clear

### create partitions ###

#create an empty GPT
echo -e "g\nw\n" | fdisk -W always "$drive"

#if installType is 3 or 4, add efi partition
if [ $installType -gt 2 ]
then
    echo -e "n\n\n\n+1G\nt\n1\nw\n" | fdisk -W always "$drive"
fi

#if installType is not 3, add boot partition
if [ $installType -lt 3 ]
then
    echo -e "n\n\n\n+1G\nt\n1\nw\n" | fdisk -W always "$drive"
elif [ $installType == 4 ]
then
    echo -e "n\n\n\n+1G\nt\n\n1\nw\n" | fdisk -W always "$drive"
fi

#add root partition
echo -e "n\n\n\n\nw\n" | fdisk -W always "$drive"

### create file systems ###

#if installType is 3 or 4, format efi partition as FAT32
if [ $installType -gt 2 ]
then
    mkfs.fat -F 32 -n EFI "$efiDrive"
fi


#if installType is 4, encrypt the boot partition 
if [ $installType == 4 ]
then
    echo -e "$bootDrivePassword\n" | cryptsetup -q --iter-time 100 luksFormat "$bootDrive"
    echo -e "$bootDrivePassword\n" | cryptsetup open "$drive"2 boot
fi

#if installType is not 3, format boot partition as FAT32
if [ $installType != 3 ]
then
    mkfs.fat -F 32 -n BOOT "$mountBootDrive"
fi

#if installType is not 1, encrypt the root partition 
if [ $installType != 1 ]
then
    echo -e "$drivePassword\n" | cryptsetup -q luksFormat "$rootDrive"
    echo -e "$drivePassword\n" | cryptsetup open "$rootDrive" root
fi

#format root Drive as Btrfs
mkfs.btrfs -f "$mountRootDrive"
mount "$mountRootDrive" /mnt
btrfs subvolume create /mnt/Artix
umount "$mountRootDrive"
mount "$mountRootDrive" -o defaults,relatime,ssd,space_cache,subvol=Artix /mnt
btrfs filesystem label /mnt Artix

#create boot directory
mkdir /mnt/boot

#if installType is not 3, mount boot partition
if [ $installType != 3 ]
then
    mount "$mountBootDrive" /mnt/boot
fi

#if installType is 3 or 4, create esp directory and mount the esp drive
if [ $installType -gt 2 ]
then
    mkdir /mnt/esp
    mount "$efiDrive" /mnt/esp
fi

#install base system
packages="base base-devel runit elogind-runit btrfs-progs cryptsetup dhcpcd dhcpcd-runit vim bash-completion linux-hardened linux-firmware linux-hardened-headers artix-archlinux-support archlinux-mirrorlist efibootmgr git go doas"
packages="$packages $drivers $desktopPackages"

#installType 3 and 4 require a different version of grub
if [ $installType -lt 3 ]
then
    packages="$packages grub"
fi

basestrap /mnt $packages

#create fstab
fstabgen -U /mnt >> /mnt/etc/fstab

#copy scripts to new root and execute in chroot
cp chroot.sh config.sh /mnt/
artix-chroot /mnt ./chroot.sh

#remove scripts
shred -u /mnt/chroot.sh /mnt/config.sh config.sh *.tar


reboot