#!/bin/bash

source config.sh

clear

#modify pacman conf
sed -i "s/#Color/Color/g; s/#ParallelDownloads = 5/ParallelDownloads = 20/g" "/etc/pacman.conf"

#add repositories to pacman conf
perl -0777 -pi -e 's/#\[lib32\]\n#/\[lib32\]\n/smg' /etc/pacman.conf
echo -e "# Arch\n\n[extra]\nInclude = /etc/pacman.d/mirrorlist-arch\n\n[community]\nInclude = /etc/pacman.d/mirrorlist-arch\n\n[multilib]\nInclude = /etc/pacman.d/mirrorlist-arch\n" >> /etc/pacman.conf
pacman-key --populate archlinux
pacman -Syyuu 

ln -sf /usr/share/zoneinfo/"$zone" /etc/localtime
ln -s /etc/runit/sv/dhcpcd /etc/runit/runsvdir/default/
hwclock --systohc

#set keyboard layout
sed -i "s/#$layout/$layout/" "/etc/locale.gen"
locale-gen

#create user, set passwords and add user to groups
echo "root:$rootPassword" | chpasswd
useradd -m -s /bin/bash $userName
echo "$userName:$userPassword" | chpasswd
usermod -a -G users $userName
usermod -a -G wheel $userName

#set hostname and hosts
echo "$compName" > /etc/hostname
echo -e "127.0.0.1	localhost\n::1		localhost\n127.0.1.1       $compName" > /etc/hosts

echo "permit nopass :wheel" > /etc/doas.conf
pacman -Rn --noconfirm sudo

sed -i "s/BINARIES=()/BINARIES=(\/usr\/sbin\/btrfs)/" "/etc/mkinitcpio.conf"
if [ $installType != 1 ]
then
    sed -i "s/HOOKS=(base udev autodetect modconf block filesystems keyboard fsck)/HOOKS=(base udev autodetect keyboard keymap modconf block encrypt filesystems keyboard fsck)/" "/etc/mkinitcpio.conf"
fi
mkinitcpio -p linux-hardened

#install yay
runuser -l $userName -c 'git clone https://aur.archlinux.org/yay.git && cd yay && makepkg --noconfirm'
pacman -U --noconfirm "/home/$userName"/yay/*.zst
rm -rf "/home/$userName/yay"

#if installType is 3 or 4, install grub with luks2 support and enable cryptodisk
if [ $installType -gt 2 ]
then
    runuser -l $userName -c 'yay -S --sudo doas --removemake --noconfirm grub-improved-luks2-git'
    sed -i "s/#GRUB_ENABLE_CRYPTODISK=y/GRUB_ENABLE_CRYPTODISK=y/" "/etc/default/grub"
fi

if [ $installType -gt 1 ]
then
    sed -i "s/GRUB_CMDLINE_LINUX=\"\"/GRUB_CMDLINE_LINUX=\"cryptdevice=UUID=$(blkid -s UUID -o value "$rootDrive"):root\"/" "/etc/default/grub"
fi


if [ $installType -lt 3 ]
then
    grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=grub
else
    grub-install --target=x86_64-efi --efi-directory=/esp --bootloader-id=grub
fi
grub-mkconfig -o /boot/grub/grub.cfg

if [ $installType == 4 ]
then
    dd bs=512 count=4 if=/dev/random of=/etc/boot.key iflag=fullblock
    echo -e "$bootDrivePassword\n" | cryptsetup luksAddKey "$bootDrive" /etc/boot.key
    echo "boot  $bootDrive  /etc/boot.key" >> /etc/crypttab
fi

