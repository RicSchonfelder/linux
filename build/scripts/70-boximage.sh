#!/bin/sh
# 70-boximage.sh - gera a imagem COMPLETA do disco p/ a tvbox
#   GPT + 1 particao FAT32 (ESP) preenchida com kernel/initrd/squashfs
#   + persist.ext4 (loop) para persistencia. GUID preservado do disco
#   original -> a entrada de boot UEFI (Boot0002) continua valida.
set -e
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
. "$ROOT/build/config/build.conf"
OUT="$ROOT/out"
IMG="$OUT/box.img"
SIZE=31268536320                              # eMMC exato (61071360 x 512)
GUID=ff5efcb7-ed2f-4884-b3ea-c8e47c130e89     # GUID original da particao 1
PERSIST_MB=3900

rm -f "$IMG" "$IMG.gz"
truncate -s "$SIZE" "$IMG"
sgdisk -Z "$IMG" >/dev/null
sgdisk -o "$IMG" >/dev/null
sgdisk -n 1:2048:0 -t 1:ef00 -c 1:ESP "$IMG" >/dev/null
sgdisk -u 1:$GUID "$IMG" >/dev/null

LOOP="$(losetup --find --show --partscan "$IMG")"
mkfs.vfat -F32 -n BOOT "${LOOP}p1" >/dev/null
UUID="$(blkid "${LOOP}p1" | sed -n 's/.*UUID="\([^"]*\)".*/\1/p')"
MNT=/mnt/boximg
mkdir -p "$MNT"
mount "${LOOP}p1" "$MNT"
mkdir -p "$MNT/EFI/BOOT" "$MNT/boot/grub" "$MNT/linux"
cp "$ROOT/rootfs/usr/share/linux/BOOTX64.EFI" "$MNT/EFI/BOOT/BOOTX64.EFI"
cp "$OUT/bzImage-$KVER" "$MNT/boot/vmlinuz"
cp "$OUT/initrd.img"    "$MNT/boot/initrd.img"
cp "$ROOT/iso/linux/rootfs.squashfs" "$MNT/linux/rootfs.squashfs"
cat > "$MNT/boot/grub/grub.cfg" <<EOF
serial --unit=0 --speed=115200
terminal_output console serial
set default=0
set timeout=5
search --no-floppy --file --set=root /boot/vmlinuz
if [ -z "\$root" ]; then search --no-floppy --label BOOT --set=root; fi
menuentry "Linux (custom, tvbox) - PERMANENTE" {
    linux  /boot/vmlinuz linuxmode=live persist=auto linuxmedia=UUID=$UUID loglevel=3 quiet console=tty0 console=ttyS0,115200
    initrd /boot/initrd.img
}
menuentry "Linux (custom, tvbox) - RAM (sem gravar)" {
    linux  /boot/vmlinuz linuxmode=live persist=none linuxmedia=UUID=$UUID loglevel=3 quiet console=tty0
    initrd /boot/initrd.img
}
EOF
echo ">> criando persist.ext4 (${PERSIST_MB} MB)"
dd if=/dev/zero of="$MNT/linux/persist.ext4" bs=1M count=$PERSIST_MB status=none
mkfs.ext2 -F -L PERSIST "$MNT/linux/persist.ext4" >/dev/null
sync
umount "$MNT"
losetup -d "$LOOP"

# cabeca usada (~4.5GB) comprimida + GPT de backup (fim do disco)
SECTORS=$(( SIZE / 512 ))
dd if="$IMG" bs=1M count=4500 status=none | gzip -1 > "$OUT/box-head.gz"
dd if="$IMG" bs=512 skip=$(( SECTORS - 33 )) count=33 status=none of="$OUT/box-tail.bin"
echo ">> box-head.gz: $(du -h "$OUT/box-head.gz" | cut -f1) | box-tail.bin: $(stat -c %s "$OUT/box-tail.bin") bytes"
