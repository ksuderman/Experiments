#!/usr/bin/env bash
set -eu
device=$1
mountpoint=$2

mkfs.ext4 $device
if [[ ! -e $mountpoint ]] ; then
    echo "Creating mount point directory $mountpoint"
    mkdir $mountpoint
fi
echo "Mounting $device"
mount $device $mountpoint
echo "Updating /etc/fstab"
echo "$device    $mountpoint    ext4    defaults    0 0" >> /etc/fstab

df -h $mountpoint

#apt update
# Don't update docker as it blocks the upgrade as even 
# with -y a user prompt is displayed 
#apt-mark hold docker.io
#apt upgrade -y
