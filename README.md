# grml-tools

Tools to work with the excellent [GRML](https://grml.org/)

## discover-chroot.sh

In situations where recovery of a linux filesystem is required, takes care of discvoery of partition layout.
At present, this is tailored to a single path:

 - Discover MDADM arrays
 - Open LUKS encrypted drives
 - Mount btrfs volumes
 - Pass through necessary mounts for a sucessful chroot.

### Arch specific notes

*mkinitcpio -P* - Will update the kernel
*grub-mkconfig -o /boot/grub/grub.cfg* - Will output the grub configuration

