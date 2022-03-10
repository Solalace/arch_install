gonna leave this here rq
```
#!/bin/bash
echo "Solace Arch Linux install Script"
timesetctl set-ntp true ; loadkeys us

#Partitions
lsblk
read drive ; cfdisk $drive
echo "Enter file systems for your partitions"
lsblk
echo "Enter the boot partition"
read bootpart ; echo "/dev/...1" ; mkfs.ext4 $bootpart 
echo "Enter the main partition"
read mainpart ; echo "/dev/...2" ; mkfs.ext4 $mainpart
#Mounting
echo "Mounting Partitions..."
mount $mainpart /mnt
mkdir /mnt/boot
mount $bootpart /mnt/boot
lsblk

#Install Essential Packages
echo "Installing Essential Packages..."
pacstrap /mnt base base-devel linux linux-firmware nano
#Making fstab file
echo "Making fstab file..."
genfstab -U /mnt >> /mnt/etc/fstab ; genfstab -U /mnt

#Chroot Arch
arch-chroot /mnt /bin/bash
echo "Installing Packages"
pacman -S networkmanager grub -y
echo "Starting NetworkManager"
systemctl enable NetworkManager
lsblk ; echo "Enter file system, /dev/... , do not include numbers"
read drive ; grub-install $drive
grub-mkconfig -o /boot/grub/grub.cfg

#Time Zone and Localization

#Creating User

#Finish
```
