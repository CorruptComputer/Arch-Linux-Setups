#! /bin/bash

REGION=""
CITY=""
HOSTNAME=""

while [ true ]; do
  echo "....................................................."
  ls /usr/share/zoneinfo
  echo "....................................................."
  echo ""
  echo "Which region would you like to use? "
  read answer

  if [[ -n "$answer" ]]; then
    REGION=$answer
    break
  else
    echo "Please enter a region."
    continue
  fi
done

while [ true ]; do
  echo "....................................................."
  ls /usr/share/zoneinfo/$REGION
  echo "....................................................."
  echo ""
  echo "Which city would you like to use? "
  read answer

  if [[ -n "$answer" ]]; then
    CITY=$answer
    break
  else
    echo "Please enter a city."
    continue
  fi
done

ln -sf /usr/share/zoneinfo/$REGION/$CITY /etc/localtime
hwclock --systohc

echo "....................................................."

echo "Please uncomment the locale in the following editor... (Press enter to continue)"
read null

nano /etc/locale.gen
locale-gen

echo "Please add the uncommented locale in the following editor... (Press enter to continue)"
read null

echo "LANG=" > /etc/locale.conf
nano /etc/locale.conf

while [ true ]; do
  echo "....................................................."
  echo ""
  echo "What is this PC's hostname? "
  read answer

  if [[ -n "$answer" ]]; then
    HOSTNAME=$answer
    break
  else
    echo "Please enter a hostname."
    continue
  fi
done

echo $hostname > /etc/hostname

echo "127.0.0.1 localhost
::1       localhost
127.0.0.1 $HOSTNAME" > /etc/hosts

echo "Please set a root password..."
passwd

USERNAME=""

while [ true ]; do
  echo "....................................................."
  echo ""
  echo "What should the username of the new user be?"
  read answer

  if [[ -n "$answer" ]]; then
    USERNAME=$answer
    break
  else
    echo "Please enter a username."
    continue
  fi
done

useradd -m -G wheel -s /bin/bash $USERNAME

systemd enable gdm

grub-install --target=i386-pc /dev/sda

echo "Everything should be done now... (press enter to continue)"
read null

exit