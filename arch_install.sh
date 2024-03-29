#!/bin/bash
echo -e "Solace Arch Linux install Script\n"
timedatectl set-ntp true ; loadkeys us
find / -name "arch_install.sh" -exec mv {} /tmp \;

#Partitions
lsblk ; echo "Enter Your Drive Type: /dev/..."
read drive ; cfdisk $drive
echo -e "Enter file systems for your partitions\n"
lsblk
echo -e "Enter the boot partition: /dev/... \n"
read bootpart ; mkfs.ext4 $bootpart 
echo -e "Enter the main partition: /dev/... \n"
read mainpart ; mkfs.ext4 $mainpart
#Mounting
echo "Mounting Partitions..."
mount $mainpart /mnt
mkdir /mnt/boot
mount $bootpart /mnt/boot
lsblk

#Install Essential Packages
echo "Installing Essential Packages..."
pacstrap /mnt --noconfirm base base-devel linux-zen linux-firmware vim
#Making fstab file
echo "Making fstab file..."
genfstab -U /mnt >> /mnt/etc/fstab ; genfstab -U /mnt

sed '1,/^#ChrootArch$/d' /tmp/arch_install.sh > /mnt/arch_install.chroot.sh
chmod +x /mnt/arch_install.chroot.sh ; arch-chroot /mnt ./arch_install.chroot.sh ; exit

#ChrootArch
echo "ChrootPart"
echo "Installing Packages..."
pacman --noconfirm -S networkmanager grub
echo "Starting NetworkManager..."
systemctl enable NetworkManager
lsblk ; echo -e "Enter file system: /dev/... \n do not include numbers\n "
read drive ; grub-install $drive
grub-mkconfig -o /boot/grub/grub.cfg

echo "Enter Root Password" ; passwd

#Time Zone and Localization
echo "Timezone Part"
ln -sf /usr/share/zoneinfo/America/New_York /etc/localtime
echo -e "en_US.UTF-8 UTF-8\nen_US ISO-8859-1" >> /etc/locale.gen ; locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
#Creating User
echo -e "Enter machine name" ; read machineName
echo $machineName > /etc/hostname
echo -e "Enter your username" ; read username ; useradd -mg wheel $username
echo -e '%wheel ALL=(ALL) ALL\nDefaults !tty_tickets' >> /etc/sudoers
echo -e "Give your user a password" ; passwd $username

echo -e "Post-installation phase\n"
#sudo su solace <<!
#installingPackages
#sudo pacman --noconfirm -S xorg xorg-xinit xorg-server \
#qemu-guest-agent spice-vdagent xf86-video-intel xf86-video-qxl \
#adobe-source-han-sans-otc-fonts adobe-source-han-serif-otc-fonts \
#noto-fonts noto-fonts-emoji noto-fonts-cjk \
#ttf-jetbrains-mono ttf-joypixels \
#bspwm sxhkd picom nitrogen \
#kitty rofi \
#git
#!
