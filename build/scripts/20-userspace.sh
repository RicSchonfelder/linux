#!/bin/sh
# 20-userspace.sh - compila BusyBox (estatico) e Dropbear (dinamico)
set -e
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
. "$ROOT/build/config/build.conf"
SRC="$ROOT/src"; OUT="$ROOT/out"
JOBS="$(nproc)"
mkdir -p "$SRC" "$OUT"

# ---------- BusyBox ----------
if [ ! -x "$SRC/busybox-$BBVER/busybox" ]; then
    cd "$SRC"
    [ -f "busybox-$BBVER.tar.bz2" ] || \
        curl -sL -o "busybox-$BBVER.tar.bz2" \
        "https://busybox.net/downloads/busybox-$BBVER.tar.bz2"
    [ -d "busybox-$BBVER" ] || tar -xf "busybox-$BBVER.tar.bz2"
    cd "busybox-$BBVER"
    make defconfig </dev/null >/dev/null
    sed -i 's/^# CONFIG_STATIC is not set/CONFIG_STATIC=y/' .config
    make -j"$JOBS" </dev/null
fi
echo ">> busybox: $SRC/busybox-$BBVER/busybox"

# ---------- Dropbear ----------
if [ ! -x "$SRC/dropbear-$DBVER/dropbear" ]; then
    cd "$SRC"
    [ -f "dropbear-$DBVER.tar.bz2" ] || \
        curl -sL -o "dropbear-$DBVER.tar.bz2" \
        "https://matt.ucc.asn.au/dropbear/releases/dropbear-$DBVER.tar.bz2"
    [ -d "dropbear-$DBVER" ] || tar -xf "dropbear-$DBVER.tar.bz2"
    cd "dropbear-$DBVER"
    ./configure --disable-zlib </dev/null >/dev/null
    # remove PIE (conflita com builds estaticos / alvo antigo)
    sed -i 's/-fPIE//; s/ -Wl,-pie//' Makefile
    make -j"$JOBS" PROGRAMS="dropbear dropbearkey scp dbclient" </dev/null
fi
echo ">> dropbear: $SRC/dropbear-$DBVER/dropbear"
