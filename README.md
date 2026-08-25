# RG-X60 New Mainline Build

Dedicated GitHub Actions build overlay for the Ruijie RG-X60 New (MT7986A, 512 MiB DDR3, 128 MiB SPI-NAND, EN8811H WAN PHY).

## Scope

- Builds against the current official `immortalwrt/immortalwrt` `master` branch.
- Adds only the small RG-X60 New board-support layer required for the fixed MTK U-Boot layout.
- Uses the fixed UBI partition: offset `0x680000`, size `0x6b00000` (107 MiB).
- Does **not** build, download, or modify BL2 or FIP.
- Preserves native nftables/firewall4, MediaTek HNAT, EN8811H, PPPoE, Wi-Fi, procd-ujail, and debugfs.
- On a fresh configuration, radios without an existing country setting receive `AU`. A retained or manually set country is never overwritten.

## Firmware flavors

Choose one under **Actions** → **Run workflow**:

- **`chizi-shared`** — the daily, lean profile for CHIZI sing-box shared eBPF. It keeps native nftables/TC support but excludes DAE/Honk-only debug/BTF, kprobe, XDP-socket, veth and NFQUEUE features.
- **`dae-honk-compat`** — a test profile for DAE/KDAE and Honk eBPF paths. It adds cgroup-BPF, kprobes/BPF events, full debug information plus BTF, BPF stream parser, XDP sockets, veth and nftables NFQUEUE. It still excludes Netkit, legacy iptables and TProxy.

Neither image embeds a DAE, Honk or sing-box core/LuCI application. The compatibility image provides the kernel and module surface needed to test them later.

## Build

Open **Actions** → **Build ImmortalWrt Mainline RG-X60 New (107MiB)** → **Run workflow**, select the required flavor, then start it.

The artifact contains the formal sysupgrade image and an initramfs image. For a normally running router, use the `*-squashfs-sysupgrade.bin` image through LuCI or `sysupgrade`; do not use the initramfs image as a normal upgrade image.

## Status

Before compiling, the workflow resolves the selected seed with `make defconfig` and checks the selected profile and package/kernel feature set. After compiling, it requires the two actual flashable images and bundles the resolved `config.full` with the artifact. Hardware installation and runtime testing remain required before treating an artifact as production-ready.
