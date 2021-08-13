+++
title = "Dual Booting Windows & Arch Linux"
date = "2020-04-25"
author = "Gregory Hill"
+++

Having spent far too much time reinstalling my desktop this weekend, I thought it best to write up the process.

Before continuing, boot into the machine's BIOS to enable `UEFI` booting and disable `Secure Boot`.

# Windows 10

1. Download the [latest image](https://www.microsoft.com/en-gb/software-download/windows10) and install it on a flash drive. 
2. Ensure that the machine boots with this flash drive in UEFI mode. 
3. Follow the wizard and delete all existing partitions.
4. Create a new partition for Windows, leaving suitable unallocated space for Linux.
5. Wait for the installation to complete and then disable fast startup.

## Create EFI Partition

The EFI partition created by Windows is 100MiB by default. To increase the size on a fresh install, drop into the command line (`Shift` + `F10`) before the partitioning step.

```shell
diskpart
list disk
select disk 0
create partition efi size=500
exit
```

# Arch Linux

Download [Arch Linux](https://archlinux.org/download/), connect a USB flash drive and find the name of the device:

```shell
lsblk -f
```

Install the image to the device:


```shell
dd if=archlinux.img of=/dev/sdX bs=16M && sync
```

## Partitioning

Run `cgdisk /dev/sdX` to view the partitions on the primary hard disk.
You should see the following partitions from the Windows installation:

```shell
1   529.0 MiB   Windows RE              Basic data partition
2   100.0 MiB   EFI system partition    EFI system partition
3   16.0 MiB    Microsoft reserver      Microsoft reserved partition
4   97.0 GiB    Microsoft basic data    Basic data partition
    140.8 GiB   free space
```

Navigate the text based partition editor and claim the remaining free space:

```shell
4   ...
5   140.8 GiB   Linux filesystem        root
```

## Encryption

Encrypt the root partition and open the new LUKS device:

```shell
cryptsetup -c aes-xts-plain64 -y --use-random luksFormat /dev/sdX5
cryptsetup luksOpen /dev/sdX5 luks
```

## Volumes

Setup a physical volume (PV) with a volume group (VG) and two logical volumes (LV):

```shell
pvcreate /dev/mapper/luks
vgcreate vg0 /dev/mapper/luks
lvcreate --size 8G vg0 --name swap
lvcreate -l +100%FREE vg0 --name root

mkfs.ext4 /dev/mapper/vg0-root
mkswap /dev/mapper/vg0-swap
```

Mount the root volume, enable the swap and mount the EFI partition created by Windows:

```shell
mount /dev/mapper/vg0-root /mnt
swapon /dev/mapper/vg0-swap
mkdir /mnt/boot
mount /dev/sdX2 /mnt/boot
```

## Installation

<!-- load-keys uk -->

### Software

```shell
pacstrap /mnt base base-devel grub efibootmgr intel-ucode dialog wpa_supplicant linux linux-firmware lvm2 dhcpcd
pacstrap /mnt zsh vim git
```

### File System Table (fstab)

```shell
genfstab -pU /mnt >> /mnt/etc/fstab
```

Add the following line to `/mnt/etc/fstab`:

```shell
tmpfs	/tmp	tmpfs	defaults,noatime,mode=1777	0	0
```

### Chroot

```shell
arch-chroot /mnt
```

### System Clock

```shell
ln -s /usr/share/zoneinfo/Europe/London /etc/localtime
hwclock --systohc --utc
```

### Hostname

```shell
echo $HOSTNAME > /etc/hostname
```

### Locale

Uncomment `en_GB.UTF-8 UTF-8` in `/etc/locale.gen` and run:

```shell
locale-gen
```

### Users

Set the root password:

```shell
passwd
```

Add a new user and set their password:

```shell
useradd -m -g users -G wheel -s /bin/zsh $USERNAME
passwd $USERNAME
```

Enter visudo:

```shell
visudo
```

Uncomment the following line:

```shell
## Uncomment to allow members of group wheel to execute any command
%wheel ALL=(ALL) ALL
```

## Bootloader

Edit `/etc/mkinitcpio.conf` and add `encrypt` and `lvm2` to `HOOKS` before `filesystems`.

Regenerate the `initramfs` with the `linux` preset:

```shell
mkinitcpio -p linux
```

Install a bootloader:

```shell
bootctl --path=/boot install
```

Edit `/boot/loader/loader.conf` and replace the contents with the following:

```shell
default arch
timeout 3
editor 0
```

Add a bootloader entry in `/boot/loader/entries/arch.conf`:

```shell
title Arch Linux
linux /vmlinuz-linux
initrd /initramfs-linux.img
options cryptdevice=UUID=${UUID}:volume root=/dev/mapper/vg0-root rw
```

Replace `${UUID}` with the UUID of your root partition. If you use vim to edit the file above, run the following command to automatically read this in:

```shell
:read ! blkid /dev/sdX5
```

## Reboot

```shell
exit
umount -R /mnt
swapoff -a
reboot
```

## Troubleshooting

If the PC boots directly to Windows, you may need to edit the Boot Configuration Data (BCD).
Open a `powershell` instance with administrator privileges and run the following command:

```powershell
bcdedit /set "{bootmgr}" path "\EFI\BOOT\BOOTX64.EFI"
```

## Addendum

Several additional components are required to make the system usable. In this section I will list the dependencies to get `Wayland` up and running with the `Sway` window manager. Access `Arch Linux` from the boot menu and login.

```shell
sudo pacman -S wayland waybar xorg-server-xwayland sway termite dmenu
```

Before starting, copy the example config to your user's home directory:

```shell
mkdir -p ~/.config/sway
cp /etc/sway/config ~/.config/sway/
```

Run `sway` from the command line or add [this](https://github.com/swaywm/sway/wiki#login-managers) to autostart.

### Yay

```shell
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
```