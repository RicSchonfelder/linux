#!/bin/sh
# 40-initramfs.sh - monta o initramfs (busybox + /init)
set -e
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
. "$ROOT/build/config/build.conf"
SRC="$ROOT/src"; OUT="$ROOT/out"; INITRD="$ROOT/initramfs"

echo ">> montando initramfs"
rm -rf "$INITRD"
mkdir -p "$INITRD/bin" "$INITRD/sbin" "$INITRD/proc" "$INITRD/sys" \
         "$INITRD/dev" "$INITRD/mnt/media" "$INITRD/mnt/rootfs" "$INITRD/newroot"

cp "$SRC/busybox-$BBVER/busybox" "$INITRD/bin/busybox"
chmod 755 "$INITRD/bin/busybox"
"$INITRD/bin/busybox" --list > /tmp/bb-applets
while read -r a; do
    ln -sf busybox "$INITRD/bin/$a"
    ln -sf ../bin/busybox "$INITRD/sbin/$a"
done < /tmp/bb-applets

cp "$ROOT/overlay-initrd/init" "$INITRD/init"
chmod 755 "$INITRD/init"

cd "$INITRD"
find . | cpio -o -H newc 2>/dev/null | gzip -9 > "$OUT/initrd.img"
echo ">> initramfs: $OUT/initrd.img ($(du -h "$OUT/initrd.img" | cut -f1))"
