# RG-X60 New Mainline Build

Dedicated GitHub Actions build overlay for the Ruijie RG-X60 New (MT7986A, 512 MiB DDR3, 128 MiB SPI-NAND, EN8811H WAN PHY).

## Scope

- Builds against the current official `immortalwrt/immortalwrt` `master` branch.
- Adds only the small RG-X60 New board-support layer required for the fixed MTK U-Boot layout.
- Uses the fixed UBI partition: offset `0x680000`, size `0x6b00000` (107 MiB).
- Does **not** build, download, or modify BL2 or FIP.
- Preserves native nftables/firewall4, MediaTek HNAT, EN8811H, PPPoE, Wi-Fi, procd-ujail, debugfs, and the BPF/TC packages needed by the shared eBPF use case.

## Build

Open **Actions** → **Build ImmortalWrt Mainline RG-X60 New (107MiB)** → **Run workflow**.

The artifact contains the formal sysupgrade image and an initramfs image. For a normally running router, use the `*-squashfs-sysupgrade.bin` image through LuCI or `sysupgrade`; do not use the initramfs image as a normal upgrade image.

## Status

The workflow validates its resolved configuration, generated DTB layout, kernel BPF/TC/debugfs requirements, image metadata, and final rootfs manifest. Hardware installation and runtime testing remain required before treating an artifact as production-ready.
