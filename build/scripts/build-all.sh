#!/bin/sh
# build-all.sh - pipeline completo
set -e
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
for s in 00-deps 10-kernel 20-userspace 30-rootfs 40-initramfs 45-bootfiles 50-iso; do
    echo "==================== $s ===================="
    "$ROOT/build/scripts/$s.sh"
done
echo ">> build concluido. Artefatos em $ROOT/artifacts/"
