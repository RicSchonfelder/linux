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

De dentro do sistema live (console ou SSH):

```
linux-install /dev/mmcblk0      # ou /dev/sdX do disco interno
# digite APAGAR para confirmar
```

O instalador cria:

| Particao | Tamanho | FS | Rotulo | Uso |
|----------|---------|----|--------|-----|
| p1 | 512 MB | FAT32 | BOOT | EFI + kernel + initrd + rootfs.squashfs |
| p2 | resto | ext2/4 | PERSIST | camada gravavel permanente + /home |

No boot, o `/init` detecta a particao `PERSIST` e usa overlayfs com
`upperdir` nela: **tudo que voce gravar permanece** entre reinicios.

## 4. Como funciona a persistencia

```
lowerdir = rootfs.squashfs (read-only, comprimido)
upperdir = /dev/<PERSIST>/linux-upper   (gravavel, permanente)
workdir  = /dev/<PERSIST>/linux-work
```

Sem PERSIST (ou `persist=none`), a camada gravavel fica em RAM e e
descartada no reboot (modo live puro).
