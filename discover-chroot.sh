#!/bin/bash

function discover_mdadm {
	mdadm --assemble --scan
}

function find_raid_devices {
	lsblk -o NAME,FSTYPE -Jb | jq -r '..|select(.fstype? == "linux_raid_member").name';
}

function find_luks_devices {
	lsblk -o NAME,FSTYPE -Jb | jq -r '..|select(.fstype? == "crypto_LUKS").name';
}

function find_btrfs_devices {
	lsblk -o NAME,FSTYPE -Jb | jq -r '..|select(.fstype? == "btrfs").name';
}

function find_open_luks {
	lsblk -o NAME,FSTYPE -Jb | jq -r "..|select(.name? == \"$1_crypt\").name";
}

function determine_raid_uuid {
	mdadm --examine /dev/$1 | grep 'Array UUID' | awk -F ' : ' '{ print $2}';
}

function open_luks {
	uuid=$(blkid -o value /dev/$1 | head -n1)
	dest="/mnt/mapper/luks-$uuid"

	if [ -z "$(find_open_luks $1)" ]; then
		cryptsetup luksOpen "/dev/$1" "luks-$uuid" 
	fi
}

function discover_luks {
	for i in $(find_luks_devices); do
		echo "" 
		open_luks $i
	done
}

function discover_btrfs {
	for i in $(find_btrfs_devices); do
		mount_btrfs_volumes $i
	done
}

function mount_btrfs_volumes {
	findmnt "/dev/mapper/$1"
	if [ $? -eq 1 ]; then
		mkdir -p "/mnt/$1"
		mount "/dev/mapper/$1" "/mnt/$1"
	fi

	cd "/mnt/$1"
	mount -t proc /proc @/proc
	mount -t sysfs /sys @/sys
	mount --rbind /dev @/dev
	mount --rbind /run @/run
	mount --rbind /sys/firmware/efi/efivars @/sys/firmware/efi/efivars/
	chroot @ /bin/mount -a
}

discover_mdadm
discover_luks
discover_btrfs
