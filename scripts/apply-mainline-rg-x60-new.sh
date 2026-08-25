#!/usr/bin/env bash
# Apply the small, auditable board-support layer required to build an official
# ImmortalWrt mainline image for the user's fixed 107MiB RG-X60-new layout.
set -euo pipefail

source_root="${1:-.}"
overlay_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

dts_source="${overlay_root}/mainline/mt7986a-ruijie-rg-x60-new-mtkuboot.dts"
dts_target="${source_root}/target/linux/mediatek/dts/mt7986a-ruijie-rg-x60-new-mtkuboot.dts"
image_mk="${source_root}/target/linux/mediatek/image/filogic.mk"
network_board="${source_root}/target/linux/mediatek/filogic/base-files/etc/board.d/02_network"

test -f "${dts_source}"
test -f "${image_mk}"
test -f "${network_board}"

install -Dm0644 "${dts_source}" "${dts_target}"

if ! grep -Fqx 'define Device/ruijie_rg-x60-new-mtkuboot' "${image_mk}"; then
	cat >> "${image_mk}" <<'EOF'

define Device/ruijie_rg-x60-new-mtkuboot
  DEVICE_VENDOR := Ruijie
  DEVICE_MODEL := RG-X60 New
  DEVICE_VARIANT := (107MiB UBI / MTK U-Boot layout)
  DEVICE_DTS := mt7986a-ruijie-rg-x60-new-mtkuboot
  DEVICE_DTS_CONFIG := config@ruijie_x60_gsw_en8811h_phy
  DEVICE_DTS_DIR := ../dts
  SUPPORTED_DEVICES := ruijie,rg-x60-new-mtkuboot ruijie,rg-x60-107m
  DEVICE_PACKAGES := kmod-mt7915e kmod-mt7986-firmware mt7986-wo-firmware kmod-phy-airoha-en8811h
  IMAGE/sysupgrade.bin := sysupgrade-tar | append-metadata
endef
TARGET_DEVICES += ruijie_rg-x60-new-mtkuboot
EOF
fi

if ! grep -Fq 'ruijie,rg-x60-new-mtkuboot' "${network_board}"; then
	awk '
		{ print }
		/^[[:space:]]*ruijie,rg-x60\|\\$/ {
			print "\trui" "jie,rg-x60-new-mtkuboot|\\"
		}
	' "${network_board}" > "${network_board}.new"
	mv "${network_board}.new" "${network_board}"
fi

grep -Fq '#include "mt7986a-ruijie-rg-x60.dtsi"' "${dts_target}"
grep -Fq 'reg = <0x680000 0x6b00000>;' "${dts_target}"
# linux,ubi is intentionally inherited from the unmodified official X60 base DTSI.
grep -Fq 'compatible = "linux,ubi";' "${source_root}/target/linux/mediatek/dts/mt7986a-ruijie-rg-x60.dtsi"
grep -Fqx 'define Device/ruijie_rg-x60-new-mtkuboot' "${image_mk}"
grep -Fq 'SUPPORTED_DEVICES := ruijie,rg-x60-new-mtkuboot ruijie,rg-x60-107m' "${image_mk}"
grep -Fq 'ruijie,rg-x60-new-mtkuboot' "${network_board}"
