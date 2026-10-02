# 03 - Build

## Requisitos

Host Linux x86_64 (testado em Ubuntu 22.04). O script `00-deps.sh` instala o
toolchain. Conexao de internet (kernel.org, busybox.net, GitHub).

## Pipeline

```
build/scripts/00-deps.sh        # toolchain
build/scripts/10-kernel.sh      # baixa+configura+compila o kernel
build/scripts/20-userspace.sh   # BusyBox (estatico) + Dropbear (dinamico)
build/scripts/30-rootfs.sh      # monta o rootfs (glibc, overlay, opencode)
build/scripts/40-initramfs.sh   # gera initrd.img
build/scripts/50-iso.sh         # gera a ISO bootavel
build/scripts/60-qemu-test.sh   # testa no QEMU
```

Ou tudo de uma vez: `build/scripts/build-all.sh`.

## Configuracao do kernel

Metodo: `make tinyconfig` + `merge_config.sh` com
`build/config/minimal-x86_64.fragment` + `make olddefconfig`.

O fragmento `minimal-x86_64.fragment` e a **fonte da verdade** do kernel:
so o hardware da tvbox. Para mudar, edite o fragmento e rode `10-kernel.sh`.

## Diretorios

```
src/         fontes (kernel, busybox, dropbear)
rootfs/      sistema montado
initramfs/   staging do initramfs
overlay/     arquivos de config versionados (etc, usr/local/bin, ...)
overlay-initrd/  arquivos do initramfs (init)
build/config/    fragmento do kernel + build.conf
out/         bzImage, System.map, initrd.img
artifacts/   ISO final + checksums
iso/         staging da ISO
docs/        esta documentacao
```

## Escrever a ISO no pendrive

```
sudo dd if=artifacts/linux-0.1.iso of=/dev/sdX bs=4M status=progress oflag=sync
```

(Substitua `/dev/sdX` pelo pendrive. **Cuidado**, apaga o dispositivo.)

## Teste

```
build/scripts/60-qemu-test.sh        # local
# ou no hardware real: boot pelo pendrive (F7/F12 no firmware)
```
