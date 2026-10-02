#!/bin/sh
# 45-bootfiles.sh - gera o bootloader EFI standalone e embarca boot files
set -e
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
. "$ROOT/build/config/build.conf"
OUT="$ROOT/out"; ROOTFS="$ROOT/rootfs"

mkdir -p "$ROOTFS/boot/grub" "$ROOTFS/usr/share/linux"

# kernel + initramfs dentro do rootfs (para instalacao/uso local)
cp "$OUT/bzImage-$KVER" "$ROOTFS/boot/vmlinuz"
cp "$OUT/initrd.img"    "$ROOTFS/boot/initrd.img"

# config embutida no EFI: acha a particao rotulada BOOT e carrega o grub.cfg
EMBED="$(mktemp)"
cat > "$EMBED" <<'EOF'
serial --unit=0 --speed=115200
terminal_input console serial
terminal_output console serial
search --no-floppy --file --set=root /boot/vmlinuz
if [ -z "$root" ]; then search --no-floppy --label BOOT --set=root; fi
set prefix=($root)/boot/grub
configfile ($root)/boot/grub/grub.cfg
EOF

echo ">> gerando BOOTX64.EFI (grub standalone)"
grub-mkstandalone -O x86_64-efi \
    -o "$ROOTFS/usr/share/linux/BOOTX64.EFI" \
    --modules="normal linux linuxefi ls search search_label search_fs_uuid \
               search_fs_file configfile echo test fat ext2 part_gpt part_msdos \
               serial all_video gfxterm font png video efi_gop efi_uga minicmd \
               cat halt reboot sleep" \
    "boot/grub/grub.cfg=$EMBED" 2>/dev/null
rm -f "$EMBED"
ls -lh "$ROOTFS/usr/share/linux/BOOTX64.EFI"
echo ">> boot files embarcados no rootfs"
