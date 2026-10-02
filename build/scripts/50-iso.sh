#!/bin/sh
# 50-iso.sh - gera a ISO bootavel (UEFI + BIOS) com squashfs do rootfs
set -e
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
. "$ROOT/build/config/build.conf"
OUT="$ROOT/out"; ISO="$ROOT/iso"; ART="$ROOT/artifacts"
mkdir -p "$ART"

echo ">> gerando rootfs.squashfs (xz)"
rm -rf "$ISO"
mkdir -p "$ISO/boot/grub" "$ISO/linux"
mksquashfs "$ROOT/rootfs" "$ISO/linux/rootfs.squashfs" \
    -comp xz -noappend -no-progress >/dev/null

cp "$OUT/bzImage-$KVER" "$ISO/boot/vmlinuz"
cp "$OUT/initrd.img"    "$ISO/boot/initrd.img"

cat > "$ISO/boot/grub/grub.cfg" <<EOF
set default=0
set timeout=5
search --no-floppy --file --set=root /boot/vmlinuz
if [ -z "\$root" ]; then search --no-floppy --label BOOT --set=root; fi

menuentry "Linux (custom, tvbox) - LIVE em RAM [padrao]" {
    linux  /boot/vmlinuz linuxmode=live persist=auto quiet console=tty0 console=ttyS0,115200
    initrd /boot/initrd.img
}
menuentry "Linux (custom, tvbox) - RAM (sem gravar)" {
    linux  /boot/vmlinuz linuxmode=live persist=none quiet console=tty0 console=ttyS0,115200
    initrd /boot/initrd.img
}
menuentry "Linux (custom, tvbox) - Verbose (debug)" {
    linux  /boot/vmlinuz linuxmode=live console=tty0 console=ttyS0,115200
    initrd /boot/initrd.img
}
EOF

echo ">> montando ISO (grub-mkrescue)"
grub-mkrescue -o "$ART/linux-$DISTRO_VER.iso" "$ISO" \
    -- -volid "$ISO_LABEL" >/dev/null 2>&1

( cd "$ART" && sha256sum "linux-$DISTRO_VER.iso" > "linux-$DISTRO_VER.iso.sha256" )
echo ">> ISO: $ART/linux-$DISTRO_VER.iso ($(du -h "$ART/linux-$DISTRO_VER.iso" | cut -f1))"
