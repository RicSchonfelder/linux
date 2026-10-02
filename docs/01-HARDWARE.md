# 01 - Hardware (inventario real da tvbox)

Coletado direto da maquina via `/sys`, `lspci`, `dmesg`.

## Resumo

| Item | Valor |
|------|-------|
| SoC | Intel Cherry Trail CR (Atom x5-Z8350) |
| CPU | 4x @ 1.44 GHz, x86_64, sem AVX2 (SSE4.2) |
| BIOS | AMI "Cherry Trail CR" |
| RAM | ~1.9 GB + swapfile 2.4 GB |
| Armazenamento | eMMC: `p1` FAT (TCBOOT, 511 MB) + `p2` ext4 (PERSIST, 28 GB) |
| Rede | Realtek RTL8168 Gigabit (`10ec:8168`) -> `r8169` |
| USB | xHCI (USB3) -> `xhci_pci`/`xhci_hcd` |
| RTC | CMOS (`PNP0B00`) -> `rtc_cmos` |
| Console | LPSS UART -> `8250_dw`; video via **efifb** (headless) |

## Drivers necessarios (usados de fato)

- **ACPI** (tudo enumerado por ACPI) + `pinctrl_cherryview`
- **Rede**: `r8169` (+ `mii`)
- **Storage**: `mmc_core`, `sdhci`, `sdhci_acpi`, `mmc_block`
- **USB**: `xhci_pci`, `usb_storage`, `usb_uas`, `usbhid`
- **Serial**: `8250`, `8250_dw`, `8250_pci`
- **RTC**: `rtc_cmos`
- **CPU freq/idle**: `x86_acpi_cpufreq`, `intel_idle`
- **FS**: `ext4`, `vfat`, `iso9660`, `squashfs`, `overlay`, `tmpfs`

## Descartados de proposito (nao usados)

`mei`/`mei_txe`/`mei_hdcp` (Intel ME), `lpc_ich`, `wmi`, `video`/`backlight`,
`pcspkr`, `snd`, `drm`/`i915`, `ata`/`sata`, `wlan`, `hwmom`, DPTF/thermals extra.

Trade-off: sem `drm`/`i915` (sem aceleracao grafica) — irrelevante para
servidor. Console sai por **efifb** (HDMI) e UART.

## Observacao sobre CPU (opencode)

O Atom x5-Z8350 **nao tem AVX2**. Por isso o opencode e embarcado na
variante **`opencode-linux-x64-baseline`** (compativel), evitando `SIGILL`.
