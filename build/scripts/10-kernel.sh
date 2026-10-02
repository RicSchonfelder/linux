#!/bin/sh
# 10-kernel.sh - baixa, configura (enxuto) e compila o kernel
set -e
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
. "$ROOT/build/config/build.conf"
SRC="$ROOT/src"; OUT="$ROOT/out"
KDIR="$SRC/linux-$KVER"
FRAG="$ROOT/build/config/minimal-x86_64.fragment"
JOBS="$(nproc)"

mkdir -p "$SRC" "$OUT"

# --- baixa ---
if [ ! -d "$KDIR" ]; then
    cd "$SRC"
    MAJ="$(echo "$KVER" | cut -d. -f1).x"
    curl -# -L -o "linux-$KVER.tar.xz" \
        "https://cdn.kernel.org/pub/linux/kernel/v${MAJ}/linux-$KVER.tar.xz"
    tar -xf "linux-$KVER.tar.xz"
fi

cd "$KDIR"
# --- configura: tinyconfig + fragmento + resolve deps ---
if [ ! -f .config ] || [ "$ROOT/build/config/.config.generated" -nt .config ]; then
    make ARCH=x86_64 tinyconfig >/dev/null
    scripts/kconfig/merge_config.sh -m .config "$FRAG" >/dev/null
    make ARCH=x86_64 olddefconfig >/dev/null
    cp .config "$ROOT/build/config/.config.generated"
fi

# --- compila ---
make ARCH=x86_64 -j"$JOBS" bzImage
cp arch/x86/boot/bzImage "$OUT/bzImage-$KVER"
cp System.map "$OUT/System.map-$KVER"
echo ">> kernel: $OUT/bzImage-$KVER ($(du -h "$OUT/bzImage-$KVER" | cut -f1))"
