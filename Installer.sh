#! /bin/bash

DISK="/dev/sda"
ROOT=""

# All of my PC's are EFI, but we want to check just in case.
echo "Checking for EFI vars..."
echo "....................................................."
ls /sys/firmware/efi/efivars
echo "....................................................."
echo ""
echo "Were the EFI vars available? (Y/n)"
read answer

if [ "$answer" = "n" ] || [ "$answer" = "N" ]; then
  echo "This script is only setup to support EFI, please fix that and try again..."
  exit
else
  echo "Contuing with EFI..."
fi

echo "Checking network availability..."
echo "....................................................."
ping -c 1 archlinux.org
echo "....................................................."
echo ""
echo "Was the network available? (Y/n)"
read answer

if [ "$answer" = "n" ] || [ "$answer" = "N" ]; then
  echo "Please get the network setup before continuing."
  exit
else
  echo "Contuing..."
fi

timedatectl set-ntp true


echo "Checking available disks..."
echo "....................................................."
fdisk -l
echo "....................................................."
echo ""
echo "Which disk would you like to use? (DEFAULT=/dev/sda)"
read answer
if [[ -n "$answer" ]]; then
  echo "Continuing with $answer..."
  DISK=$answer
else
  echo "Continuing with default $DISK..."
fi

echo "Please partition the disk..."
echo "Make 3 partitions: 1 primary +1G, EFI System; 2 primary -8G, Linux Filesystem; 3 primary, Linux Swap."
echo "....................................................."
fdisk $DISK
echo "....................................................."
echo "Here is the partition table for $DISK..."
fdisk -l $DISK

echo "....................................................."
echo ""
while [ true ]; do
  echo "Where do you want the EFI System? "
  read answer

  if [[ -n "$answer" ]]; then
    mkfs.fat -F32 $answer
    break
  else
    echo "Please enter a partition."
    continue
    
  fi
done

echo "....................................................."
echo ""
while [ true ]; do
  echo "Where do you want the root filesystem? "
  read answer

  if [[ -n "$answer" ]]; then
    mkfs.ext4 $answer
    ROOT=$answer
    break
  else
    echo "Please enter a partition."
    continue
    
  fi
done

echo "....................................................."
echo ""
while [ true ]; do
  echo "Where do you want the swap? "
  read answer

  if [[ -n "$answer" ]]; then
    mkswap $answer
    swapon $answer
    break
  else
    echo "Please enter a partition."
    continue
  fi
done

mount $ROOT /mnt

pacstrap /mnt base base-devel linux linux-firmware gnome gdm vim sudo grub efibootmgr dosfstools

genfstab -U /mnt >> /mnt/etc/fstab

wget https://raw.githubusercontent.com/CorruptComputer/Arch-Linux-Setups/master/InstallerAfterChroot.sh
cp InstallerAfterChroot.sh /mnt/InstallerAfterChroot.sh

echo "The initial install is done, we need to chroot now. When you get the prompt for the new shell run the InstallerAfterChroot.sh file... (press enter to continue)"
read null

arch-chroot /mnt

echo "Press enter to reboot..."
read null
reboot
