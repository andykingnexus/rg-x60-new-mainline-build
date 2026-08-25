#!/usr/bin/env bash
# Validate the resolved OpenWrt configuration before the expensive build.
# This deliberately does not inspect generated kernel artefacts after build.
set -euo pipefail

flavor=${1:?firmware flavor is required}
config=${2:?resolved .config is required}
profile=${3:?device profile is required}

fail() {
  echo "Configuration error: $*" >&2
  exit 1
}

require_y() {
  grep -Fxq "$1=y" "$config" || fail "required: $1=y"
}

require_disabled() {
  if grep -Eq "^$1=(y|m)$" "$config"; then
    fail "must stay disabled: $1"
  fi
}

target_count=$(grep -Ec '^CONFIG_TARGET_mediatek_filogic_DEVICE_.*=y$' "$config" || true)
[ "$target_count" -eq 1 ] || fail "expected exactly one Filogic device profile"
grep -Fxq "CONFIG_TARGET_mediatek_filogic_DEVICE_${profile}=y" "$config" || \
  fail "selected device profile is not ${profile}"

common_required=(
  CONFIG_TARGET_ROOTFS_INITRAMFS
  CONFIG_KERNEL_DEBUG_FS
  CONFIG_KERNEL_FTRACE
  CONFIG_KERNEL_FUNCTION_TRACER
  CONFIG_KERNEL_DYNAMIC_FTRACE
  CONFIG_PACKAGE_mtd
  CONFIG_PACKAGE_firewall4
  CONFIG_PACKAGE_nftables-json
  CONFIG_PACKAGE_kmod-nft-core
  CONFIG_PACKAGE_kmod-nft-fib
  CONFIG_PACKAGE_kmod-nft-nat
  CONFIG_PACKAGE_kmod-nft-offload
  CONFIG_PACKAGE_kmod-sched-core
  CONFIG_PACKAGE_kmod-sched-bpf
  CONFIG_PACKAGE_kmod-inet-diag
  CONFIG_PACKAGE_kmod-netlink-diag
  CONFIG_PACKAGE_kmod-tun
  CONFIG_PACKAGE_kmod-phy-airoha-en8811h
  CONFIG_PACKAGE_airoha-en8811h-firmware
  CONFIG_PACKAGE_procd-ujail
)
for symbol in "${common_required[@]}"; do require_y "$symbol"; done

# Both flavors stay on firewall4/native nftables; no legacy iptables or TProxy.
common_disabled=(
  CONFIG_PACKAGE_bridger
  CONFIG_PACKAGE_ebtables
  CONFIG_PACKAGE_ip6tables-nft
  CONFIG_PACKAGE_ipset
  CONFIG_PACKAGE_iptables-nft
  CONFIG_PACKAGE_xtables-nft
  CONFIG_PACKAGE_kmod-ebtables
  CONFIG_PACKAGE_kmod-ebtables-ipv4
  CONFIG_PACKAGE_kmod-ebtables-ipv6
  CONFIG_PACKAGE_kmod-ip6tables
  CONFIG_PACKAGE_kmod-ipt-compat-xtables
  CONFIG_PACKAGE_kmod-ipt-core
  CONFIG_PACKAGE_kmod-ipt-ipset
  CONFIG_PACKAGE_kmod-ipt-tproxy
  CONFIG_PACKAGE_kmod-iptables
  CONFIG_PACKAGE_kmod-nf-ipt
  CONFIG_PACKAGE_kmod-nf-ipt6
  CONFIG_PACKAGE_kmod-nf-socket
  CONFIG_PACKAGE_kmod-nf-tproxy
  CONFIG_PACKAGE_kmod-nft-compat
  CONFIG_PACKAGE_kmod-nft-socket
  CONFIG_PACKAGE_kmod-nft-tproxy
  CONFIG_PACKAGE_iptables-mod-tproxy
  CONFIG_PACKAGE_libipset
  CONFIG_PACKAGE_libiptext
  CONFIG_PACKAGE_libiptext-nft
  CONFIG_PACKAGE_libiptext6
  CONFIG_PACKAGE_libxtables
)
for symbol in "${common_disabled[@]}"; do require_disabled "$symbol"; done

case "$flavor" in
  chizi-shared)
    for symbol in \
      CONFIG_KERNEL_KPROBES \
      CONFIG_KERNEL_KPROBE_EVENTS \
      CONFIG_KERNEL_BPF_EVENTS \
      CONFIG_KERNEL_DEBUG_INFO \
      CONFIG_KERNEL_DEBUG_INFO_BTF \
      CONFIG_KERNEL_DEBUG_INFO_BTF_MODULES \
      CONFIG_KERNEL_BPF_STREAM_PARSER \
      CONFIG_KERNEL_NETKIT \
      CONFIG_KERNEL_XDP_SOCKETS \
      CONFIG_PACKAGE_kmod-veth \
      CONFIG_PACKAGE_kmod-nfnetlink-queue \
      CONFIG_PACKAGE_kmod-nft-queue \
      CONFIG_PACKAGE_kmod-xdp-sockets-diag
    do
      require_disabled "$symbol"
    done
    ;;
  dae-honk-compat)
    for symbol in \
      CONFIG_KERNEL_CGROUPS \
      CONFIG_KERNEL_CGROUP_BPF \
      CONFIG_KERNEL_KPROBES \
      CONFIG_KERNEL_KPROBE_EVENTS \
      CONFIG_KERNEL_BPF_EVENTS \
      CONFIG_KERNEL_DEBUG_INFO \
      CONFIG_KERNEL_DEBUG_INFO_BTF \
      CONFIG_KERNEL_BPF_STREAM_PARSER \
      CONFIG_KERNEL_XDP_SOCKETS \
      CONFIG_PACKAGE_kmod-veth \
      CONFIG_PACKAGE_kmod-nfnetlink-queue \
      CONFIG_PACKAGE_kmod-nft-queue \
      CONFIG_PACKAGE_kmod-xdp-sockets-diag
    do
      require_y "$symbol"
    done
    require_disabled CONFIG_KERNEL_DEBUG_INFO_REDUCED
    require_disabled CONFIG_KERNEL_DEBUG_INFO_BTF_MODULES
    require_disabled CONFIG_KERNEL_NETKIT
    ;;
  *)
    fail "unknown firmware flavor: $flavor"
    ;;
esac

echo "Resolved configuration is valid for flavor: $flavor"
