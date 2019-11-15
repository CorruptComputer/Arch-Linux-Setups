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


echo "Partitioning the disk..."
echo "Making 3 partitions: 1 primary +1G, EFI System; 2 primary -8G, Linux Filesystem; 3 primary, Linux Swap."
echo "....................................................."
# Found here: https://superuser.com/questions/332252/how-to-create-and-format-a-partition-using-a-bash-script
# to create the partitions programatically (rather than manually)
# we're going to simulate the manual input to fdisk
# The sed script strips off all the comments so that we can 
# document what we're doing in-line with the actual commands
# Note that a blank line (commented as "defualt" will send a empty
# line terminated with a newline to take the fdisk default.
sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << EOF | fdisk $DISK
  g   # GPT partition table
  n   # new partition
  1   # partition number 1
      # default beginning
  +1G # end 1GB later
  t   # change type
  1   # type 1, EFI System
  n   # new partition
  2   # partition number 2
      # default beginning
  -8G # end 8GB before the end of the disk
  n   # new partition
  3   # partition number 3
      # default beginning
      # default ending
  t   # change partition type
  3   # partition number 3
  19  # type 19, Linux Swap
  w   # write disk
EOF
echo "....................................................."
echo "Here is the partition table for $DISK..."
fdisk -l $DISK

echo "....................................................."
echo "EFI System being created here: $DISK"1
mkfs.fat -F32 "$DISK"1
echo "....................................................."
echo "Linux Filesystem being created here: $DISK"2
mkfs.ext4 "$DISK"2
echo "....................................................."
echo "Linux Swap being created here: $DISK"3
mkswap "$DISK"3
swapon "$DISK"3
echo "....................................................."

mount "$DISK"2 /mnt

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
