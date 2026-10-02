#!/bin/sh
# 30-rootfs.sh - monta o sistema de arquivos (BusyBox + glibc + Dropbear + overlay)
set -e
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
. "$ROOT/build/config/build.conf"
SRC="$ROOT/src"; OUT="$ROOT/out"; ROOTFS="$ROOT/rootfs"
GLIB=/lib/x86_64-linux-gnu

echo ">> limpando rootfs"
rm -rf "$ROOTFS"
mkdir -p "$ROOTFS"
cd "$ROOTFS"
mkdir -p usr/bin usr/local/bin usr/share/udhcpc \
         lib/x86_64-linux-gnu lib64 \
         etc/init.d etc/dropbear etc/ssl/certs \
         root/.ssh home var/log var/backup \
         tmp run mnt proc sys dev dev/pts opt

# ---------- BusyBox (estatico) ----------
echo ">> instalando BusyBox"
cp "$SRC/busybox-$BBVER/busybox" usr/bin/busybox
chmod 755 usr/bin/busybox
usr/bin/busybox --list > /tmp/bb-applets
while read -r a; do ln -sf busybox "usr/bin/$a"; done < /tmp/bb-applets
# usr-merge: /bin,/sbin -> /usr/bin ; /usr/sbin -> bin
ln -s usr/bin bin
ln -s usr/bin sbin
ln -s bin usr/sbin

# ---------- Dropbear (dinamico glibc) ----------
echo ">> instalando Dropbear"
cp "$SRC/dropbear-$DBVER/dropbear"    usr/sbin/dropbear
cp "$SRC/dropbear-$DBVER/dropbearkey" usr/bin/dropbearkey
cp "$SRC/dropbear-$DBVER/dbclient"    usr/bin/dbclient
cp "$SRC/dropbear-$DBVER/scp"         usr/bin/scp
chmod 755 usr/sbin/dropbear usr/bin/dropbearkey usr/bin/dbclient usr/bin/scp

# ---------- runtime glibc (necessario p/ opencode e dropbear) ----------
echo ">> copiando runtime glibc"
for f in libc.so.6 libm.so.6 libpthread.so.0 libdl.so.2 librt.so.1 \
         libresolv.so.2 libcrypt.so.1 libgcc_s.so.1 \
         libnss_files.so.2 libnss_dns.so.2; do
    [ -e "$GLIB/$f" ] && cp -aL "$GLIB/$f" lib/x86_64-linux-gnu/
done
# loader dinamico: copiar o ARQUIVO real (dereferenciado) nos dois caminhos,
# evitando loop de symlink (era a causa do ELOOP)
LOADER="$(readlink -f /lib64/ld-linux-x86-64.so.2)"
cp -a "$LOADER" lib64/ld-linux-x86-64.so.2
cp -a "$LOADER" lib/x86_64-linux-gnu/ld-linux-x86-64.so.2

# ---------- CA certificates ----------
[ -f /etc/ssl/certs/ca-certificates.crt ] && \
    cp -a /etc/ssl/certs/ca-certificates.crt etc/ssl/certs/

# ---------- firmware (NIC Realtek r8169 da tvbox) ----------
mkdir -p lib/firmware/rtl_nic
if ls /lib/firmware/rtl_nic/*.fw >/dev/null 2>&1; then
    cp -a /lib/firmware/rtl_nic/. lib/firmware/rtl_nic/
    echo ">> firmware rtl_nic: $(ls lib/firmware/rtl_nic | wc -l) arquivos"
fi

# ---------- overlay (arquivos de configuracao) ----------
echo ">> aplicando overlay"
cp -a "$ROOT/overlay/." "$ROOTFS/"

# ---------- opencode (embarcado, baseline/glibc) ----------
echo ">> embarcando opencode ($OC_ASSET)"
mkdir -p opt/opencode
curl -sL "https://github.com/$OC_REPO/releases/latest/download/$OC_ASSET" \
    | tar -xz -C opt/opencode
chmod 755 opt/opencode/opencode
ln -sf /opt/opencode/opencode usr/local/bin/opencode

# ---------- permissoes ----------
chmod 700 etc/dropbear root root/.ssh
chmod 600 etc/shadow root/.ssh/authorized_keys
chmod 755 etc/init.d/rcS etc/init.d/network etc/init.d/dropbear
chmod 755 usr/local/bin/opencode-install usr/local/bin/linux-update usr/local/bin/linux-install
chmod 755 usr/share/udhcpc/default.script
ln -sf /proc/mounts etc/mtab

echo ">> rootfs pronto: $(du -sh "$ROOTFS" | cut -f1)"
