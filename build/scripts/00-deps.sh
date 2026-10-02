#!/bin/sh
# 00-deps.sh - instala o toolchain de build (Ubuntu/Debian)
set -e
SUDO=""
[ "$(id -u)" != 0 ] && SUDO="sudo"
export DEBIAN_FRONTEND=noninteractive
$SUDO apt-get update -qq
$SUDO apt-get install -y -qq \
    build-essential bison flex bc libssl-dev libelf-dev libncurses-dev \
    cpio rsync xorriso dosfstools mtools \
    qemu-system-x86 syslinux isolinux syslinux-efi syslinux-common \
    grub-efi-amd64-bin grub-pc-bin grub-common \
    squashfs-tools busybox-static file
echo ">> toolchain instalado."
