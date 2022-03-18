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
pacstrap /mnt base base-devel linux linux-firmware nano -y
#Making fstab file
echo "Making fstab file..."
genfstab -U /mnt >> /mnt/etc/fstab ; genfstab -U /mnt

sed '1,/^#ChrootArch$/d' /tmp/arch_install.sh > /mnt/arch_install.chroot.sh
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

echo "Post-installation phase"
dots_install=/home/$username/arch_dotfiles.sh
sed '1,/^#Dotfiles$/d' arch_install.chroot.sh > $dots_install
chown $username:$username $dots_install
chmod +x $dots_install ; su -c $dots_install -s /bin/sh $username ; exit

#Dotfiles
#Installing Packages
sudo pacman -S xorg xorg-xinit xorg-server xf86-video-intel \
bspwm sxhkd picom kitty \
#rofi nitrogen \ 

#umount -R /mnt ; reboot
