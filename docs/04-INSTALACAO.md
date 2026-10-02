# 04 - Instalacao (permanente)

## Requisitos

- Um pendrive (>= 1 GB) para a ISO, **ou** o proprio disco da maquina.
- Acesso a UEFI/BIOS para escolher o dispositivo de boot (F7/F12).

## 1. Gravar a ISO no pendrive

```
sudo dd if=artifacts/linux-0.1.iso of=/dev/sdX bs=4M status=progress oflag=sync
```

## 2. Boot

Insira o pendrive, ligue a maquina e escolha o pendrive no menu de boot.
O menu do GRUB oferece:

- **LIVE em RAM** (padrao): roda tudo na memoria, nao grava nada.
- **Rootdir**: usa o squashfs direto (menos RAM).

Login: `root` / senha `linux`. SSH ja sobe na porta 22 (dropbear).

## 3. Instalar em definitivo (permanente)

O esquema usa **uma unica particao** FAT32 (ESP) no disco interno, com a
persistencia em arquivo ext4 (loop) dentro dela. Faca o boot pelo **pendrive
(LIVE)** e rode:

```
linux-install /dev/mmcblk0      # ou /dev/sdX do disco interno
```

O comando copia para a particao do disco: bootloader EFI, kernel, initrd,
`rootfs.squashfs` e garante o `persist.ext4` (label PERSIST).

| Item | Valor |
|------|-------|
| Particao | 1x FAT32 (ESP), GPT |
| Bootloader | `/EFI/BOOT/BOOTX64.EFI` (GRUB standalone) |
| Sistema | `/linux/rootfs.squashfs` |
| Persistencia | `/linux/persist.ext4` (ext4, loop, ~3.9 GB) |

No boot, o `/init` monta o squashfs (read-only) e usa o `persist.ext4` como
camada de escrita (overlayfs) — **tudo que voce gravar permanece**.

## 4. Como funciona a persistencia

```
lowerdir = rootfs.squashfs          (read-only, comprimido)
upperdir = /linux/persist.ext4      (ext4 em loop, gravavel, permanente)
workdir  = /linux/persist.ext4
```

O `persist.ext4` fica na propria particao FAT (arquivo-imagem). Sem ele
(ou com `persist=none`), a camada gravavel fica na RAM e e descartada no
reboot (modo live puro).
