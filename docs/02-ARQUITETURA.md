# 02 - Arquitetura

## Fluxo de boot

```
Firmware UEFI/BIOS
   |
   v
GRUB (ISO: BIOS isolinux + EFI)  -> vmlinuz + initrd.img
   |
   v
/init (initramfs, BusyBox)
   |-- monta proc/sys/dev
   |-- acha a midia de boot (procura /linux/rootfs.squashfs)
   |-- monta rootfs.squashfs
   |-- MODO LIVE  (padrao): copia tudo p/ tmpfs (RAM) -> switch_root
   |-- MODO ROOTDIR: usa o squashfs direto (instalado)
   |
   v
/sbin/init (BusyBox init) -> /etc/inittab
   |-- rcS: monta, hostname, /etc/init.d/network (DHCP), dropbear
   |-- getty em tty1 (HDMI) + ttyS0 (serial, se houver)
   |
   v
Sistema pronto: SSH (dropbear:22) + shell + opencode
```

## Componentes

| Camada | Escolha | Motivo |
|--------|---------|--------|
| Kernel | 6.12.111 LTS, monolitico | estabilidade, sem modulos = simples para live |
| Userspace base | BusyBox estatico | 1 binario, ~2.5 MB, init+coreutils+shell |
| libc | glibc (runtime) | opencode e dropbear sao glibc |
| SSH | Dropbear | leve (~281 KB) vs OpenSSH |
| Sistema de arquivos raiz | squashfs (xz) | comprimido, read-only, ideal p/ RAM |
| Persistencia | overlayfs | camada gravavel sobre o squashfs |

## Layout da ISO

```
/boot/vmlinuz              kernel
/boot/initrd.img           initramfs (busybox + /init)
/boot/grub/grub.cfg        menu (live / rootdir / verbose)
/linux/rootfs.squashfs     sistema completo
/EFI/BOOT/...              boot UEFI
/isolinux, /boot/isolinux  boot BIOS
```

## Modos de operacao

- **LIVE (padrao)**: copia o squashfs para tmpfs -> tudo em RAM. O pendrive
  pode ate ser removido depois do boot. Nada e gravado na midia.
- **ROOTDIR**: usa o squashfs direto (menos RAM, mais lento por xz).
- **INSTALADO**: rootfs gravado no eMMC/disco; boot sem initramfs de copia.

## Atualizacoes (GitHub)

O comando `linux-update` consulta o repo, baixa o pacote de release
(`linux-rootfs-<ver>.tar.gz` + `.sha256`), valida checksum e aplica sobre `/`
(com backup previo em `/var/backup`). `opencode-install` faz o mesmo para o
binario do opencode.

## Repositorio

`https://github.com/ricschonfelder/linux`
