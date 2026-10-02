#!/bin/sh
# 60-qemu-test.sh - teste de boot da ISO no QEMU (serial)
set -e
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
. "$ROOT/build/config/build.conf"
ART="$ROOT/artifacts"
ISO="$ART/linux-$DISTRO_VER.iso"
[ -f "$ISO" ] || { echo "ISO nao encontrada: $ISO"; exit 1; }

KVM=""
[ -w /dev/kvm ] && KVM="-enable-kvm"

echo ">> bootando $ISO no QEMU (Ctrl-A x para sair)"
exec qemu-system-x86_64 $KVM -m 2048 -smp 2 \
    -cdrom "$ISO" -boot d \
    -display none -serial mon:stdio
