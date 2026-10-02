# 05 - Atualizacoes e GitHub

## Repositorio

Codigo-fonte, scripts e configs ficam no GitHub:

```
https://github.com/ricschonfelder/linux
```

O repositorio guarda **apenas codigo** (scripts de build, config do kernel,
overlay, docs). Arquivos grandes (ISO, kernel, squashfs) **nao** vao para o
git — vao como **assets de Release**.

## Atualizacao do sistema (no dispositivo)

O comando `linux-update` consulta o ultimo Release do repo:

```
linux-update
```

- Compara `/etc/linux-version` com a ultima tag.
- Baixa `linux-rootfs-<ver>.tar.gz` + `.sha256`.
- Valida o checksum e aplica sobre `/` (backup em `/var/backup`).

## Atualizacao do opencode

```
opencode-install
```

Baixa sempre a ultima release `opencode-linux-x64-baseline.tar.gz`
(glibc, sem AVX2 — compativo com o Atom x5-Z8350) e instala em `/opt/opencode`.

## Publicar uma nova versao (no host de build)

1. Ajuste `DISTRO_VER` em `build/config/build.conf`.
2. Rode `build/scripts/build-all.sh`.
3. Empacote o rootfs:

```
tar -C rootfs -czf linux-rootfs-<ver>.tar.gz .
sha256sum linux-rootfs-<ver>.tar.gz > linux-rootfs-<ver>.tar.gz.sha256
```

4. Crie o Release e anexe os arquivos:

```
gh release create v<ver> linux-rootfs-<ver>.tar.gz linux-rootfs-<ver>.tar.gz.sha256 \
   artifacts/linux-<ver>.iso --title "Linux <ver>" --notes "..."
```

## Estrutura de versao

- `/etc/linux-version` — versao instalada no dispositivo.
- Tags do repo: `v0.1`, `v0.2`, ...
