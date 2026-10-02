# Linux (distro custom)

Distro Linux **feita do zero** para a TV box (Intel Cherry Trail / Atom
x5-Z8350). Servidor **headless** (SSH + opencode + dev) que:

- **Live**: liga do pendrive e roda com overlay em **RAM** (nada gravado na midia).
- **Permanente**: instalada no eMMC/disco, com **persistencia** via overlayfs.
- Conecta na internet automaticamente, sobe `sshd` (dropbear) e abre `opencode`.
- Recebe **atualizacoes via GitHub**.

- Usuario: `root`  |  Senha: `linux`
- Kernel: 6.12.111 LTS, **enxuto** (2.7 MB, 0 modulos, so o hardware da tvbox)
- Console: HDMI (efifb) + serial LPSS UART

## Documentacao

Comece por [`docs/00-VISAO.md`](docs/00-VISAO.md):

| Doc | Assunto |
|-----|---------|
| 00 | Visao geral |
| 01 | Hardware real da tvbox + drivers |
| 02 | Arquitetura e fluxo de boot |
| 03 | Build (comandos) |
| 04 | Instalacao (pendrive / permanente) |
| 05 | Atualizacoes e GitHub |

## Build rapido

```
build/scripts/00-deps.sh       # toolchain
build/scripts/10-kernel.sh     # baixa + compila o kernel
build/scripts/20-userspace.sh  # BusyBox + Dropbear
build/scripts/30-rootfs.sh     # monta o rootfs
build/scripts/40-initramfs.sh  # initrd
build/scripts/45-bootfiles.sh  # bootloader EFI
build/scripts/50-iso.sh        # ISO bootavel
build/scripts/60-qemu-test.sh  # teste no QEMU
```

Ou: `build/scripts/build-all.sh`.

Resultado: `artifacts/linux-<ver>.iso`.

## Estrutura

```
docs/            documentacao
build/           scripts de build + config (fragmento do kernel, build.conf)
overlay/         arquivos do sistema versionados (etc, usr/local/bin, ...)
overlay-initrd/  init do initramfs
src/             fontes (baixados no build)
out/ rootfs/ initramfs/ iso/ artifacts/   (gerados)
```
