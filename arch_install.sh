#!/bin/bash
echo -e "Solace Arch Linux install Script\n"
timedatectl set-ntp true ; loadkeys us
#find /*/arch_install.sh -maxdepth 1 -exec mv {} /tmp \;
mv /root/arch_install.sh /tmp/

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
pacstrap /mnt base base-devel linux linux-firmware nano -y
#Making fstab file
echo "Making fstab file..."
genfstab -U /mnt >> /mnt/etc/fstab ; genfstab -U /mnt

sed '1,/^#ChrootArch$/d' /tmp/Dotfiles/arch_install.sh > /mnt/arch_install.chroot.sh
chmod +x /mnt/arch_install.chroot.sh ; arch-chroot /mnt ./arch_install.chroot.sh ; exit

#ChrootArch
echo "ChrootPart"
echo "Installing Packages..."
pacman -S networkmanager grub -y
echo "Starting NetworkManager..."
systemctl enable NetworkManager
lsblk ; echo -e "Enter file system: /dev/... \n do not include numbers\n "
read drive ; grub-install $drive
grub-mkconfig -o /boot/grub/grub.cfg

echo "Enter Root Password" ; passwd

#Time Zone and Localization
echo "TimeZone Part"
ln -sf /usr/share/zoneinfo/America/New_York /etc/localtime
echo -ne "
en_US.UTF-8 UTF-8
en_US ISO-8859-1  " >> /etc/locale.gen ; locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
#Creating User
echo -e "Enter machine name" ; read machineName
echo $machineName > /etc/hostname
echo -e "Enter your username" ; read username ; useradd -mg wheel $username ;
echo -e "Give your user a password" ; passwd $username
echo -ne "%wheel ALL=(ALL) ALL
Defaults !tty_tickets" >> /etc/sudoers

#Finish and/or Dotfiles
echo "Script has now finished, post-installation phase"
#umount -R /mnt ; reboot
