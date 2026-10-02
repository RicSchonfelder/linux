#!/bin/sh
# 72-pendrive.sh - gera a imagem do pendrive (MBR + FAT32, boot UEFI + legado)
#   Compat: BIOS AMI costuma listar melhor USB em MBR/FAT32.
#   Saida: out/pendrive.img (gravar com dd) e out/pd-head/pd-tail opcionais.
set -e
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
. "$ROOT/build/config/build.conf"
OUT="$ROOT/out"
IMG="$OUT/pendrive.img"
SIZE="${PD_SIZE:-1073741824}"     # 1 GiB por padrao

rm -f "$IMG"
truncate -s "$SIZE" "$IMG"
sfdisk "$IMG" >/dev/null <<EOF
label: dos
unit: sectors
2048,+,c,*
EOF
LOOP="$(losetup --find --show --partscan "$IMG")"
mkfs.vfat -F32 -n BOOT "${LOOP}p1" >/dev/null
UUID="$(blkid "${LOOP}p1" | sed -n 's/.*UUID="\([^"]*\)".*/\1/p')"
MNT=/mnt/pendrive
mkdir -p "$MNT"
mount "${LOOP}p1" "$MNT"
mkdir -p "$MNT/EFI/BOOT" "$MNT/boot/grub" "$MNT/linux"
cp "$ROOT/rootfs/usr/share/linux/BOOTX64.EFI" "$MNT/EFI/BOOT/BOOTX64.EFI"
cp "$OUT/bzImage-$KVER" "$MNT/boot/vmlinuz"
cp "$OUT/initrd.img"    "$MNT/boot/initrd.img"
cp "$ROOT/iso/linux/rootfs.squashfs" "$MNT/linux/rootfs.squashfs"
cat > "$MNT/boot/grub/grub.cfg" <<EOF
set default=0
set timeout=5
serial --unit=0 --speed=115200
terminal_output console serial
search --no-floppy --file --set=root /boot/vmlinuz
if [ -z "\$root" ]; then search --no-floppy --label BOOT --set=root; fi
menuentry "Linux (custom, tvbox) - LIVE (persistente)" {
    linux  /boot/vmlinuz linuxmode=live persist=auto linuxmedia=UUID=$UUID loglevel=3 quiet console=tty0 console=ttyS0,115200
    initrd /boot/initrd.img
}
menuentry "Linux (custom, tvbox) - RAM (sem gravar)" {
    linux  /boot/vmlinuz linuxmode=live persist=none linuxmedia=UUID=$UUID loglevel=3 quiet console=tty0
    initrd /boot/initrd.img
}
EOF
# boot legado (BIOS) via syslinux
dd if=/usr/lib/syslinux/mbr/mbr.bin of="$LOOP" bs=440 count=1 conv=notrunc >/dev/null 2>&1 || true
syslinux --install "${LOOP}p1" 2>/dev/null || true
cp /usr/lib/syslinux/modules/bios/*.c32 "$MNT/" 2>/dev/null || true
cat > "$MNT/syslinux.cfg" <<EOF
DEFAULT linux
TIMEOUT 50
PROMPT 0
LABEL linux
  KERNEL /boot/vmlinuz
  INITRD /boot/initrd.img
  APPEND linuxmode=live persist=auto linuxmedia=UUID=$UUID loglevel=3 console=tty0 console=ttyS0,115200
LABEL ram
  KERNEL /boot/vmlinuz
  INITRD /boot/initrd.img
  APPEND linuxmode=live persist=none linuxmedia=UUID=$UUID loglevel=3 console=tty0
EOF
sync
umount "$MNT"
losetup -d "$LOOP"
echo ">> pendrive: $IMG ($(du -h "$IMG" | cut -f1)) uuid=$UUID"
