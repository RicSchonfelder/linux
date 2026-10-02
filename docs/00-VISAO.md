# 00 - Visao

## O que e

Uma distribuicao Linux **propria**, construida do zero, para a TV box com
SoC **Intel Cherry Trail (Atom x5-Z8350)**. Servidor **headless** com SSH e
opencode, que roda **na RAM a partir de um pendrive** e tambem pode ser
**instalada em definitivo** na maquina.

## Objetivos

| # | Requisito |
|---|-----------|
| 1 | Linux do zero: kernel proprio, compilado e configurado para o hardware real |
| 2 | Kernel **enxuto**: apenas drivers usados pela tvbox, tudo built-in |
| 3 | Headless: SSH (dropbear) + opencode + ferramentas de dev |
| 4 | Live: liga do pendrive e roda **100% na RAM** (nao grava no pendrive) |
| 5 | Instalado: gravado no eMMC/disco e permanece |
| 6 | Rede automatica (DHCP) e **acesso remoto** ja no boot |
| 7 | Atualizacoes/recursos via **GitHub** |
| 8 | Usuario `root`, senha `linux` |

## Identidade

- Nome do sistema: **Linux** (custom)
- Hostname: `linux`
- Usuario: `root` / senha: `linux`

## Estado atual

- [x] Toolchain no `lab`
- [x] Kernel 6.12.111 LTS enxuto (2.7 MB, 0 modulos) para o Cherry Trail
- [x] BusyBox estatico + Dropbear (SSH)
- [x] Rootfs minimo (glibc + overlay + opencode embarcado)
- [x] Initramfs com modo RAM (overlay em RAM)
- [x] ISO bootavel (UEFI + BIOS) — 74 MB
- [x] Instalador permanente (`linux-install`) + persistencia (particao PERSIST)
- [x] Boot validado no QEMU: overlay + dropbear:22 + login
- [x] opencode validado no rootfs (Bun baseline, glibc)
- [x] Repositorio GitHub privado (`github.com/RicSchonfelder/linux`)
- [ ] Release v0.1 com a ISO
- [ ] Teste em hardware real (tvbox)
