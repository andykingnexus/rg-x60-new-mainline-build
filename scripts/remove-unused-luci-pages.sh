#!/usr/bin/env bash
# Remove two optional LuCI views from the assembled feed before packaging.
# luci-mod-system and luci-mod-network remain installed because they provide
# core router administration; only these independent menu views are removed.
set -euo pipefail

tree=${1:?OpenWrt source directory is required}
system_view="$tree/feeds/luci/modules/luci-mod-system/htdocs/luci-static/resources/view/system/plugins.js"
network_view="$tree/feeds/luci/modules/luci-mod-network/htdocs/luci-static/resources/view/network/diagnostics.js"
system_menu="$tree/feeds/luci/modules/luci-mod-system/root/usr/share/luci/menu.d/luci-mod-system.json"
network_menu="$tree/feeds/luci/modules/luci-mod-network/root/usr/share/luci/menu.d/luci-mod-network.json"

for path in "$system_view" "$network_view" "$system_menu" "$network_menu"; do
  test -f "$path" || {
    echo "Expected LuCI source file is missing: $path" >&2
    exit 1
  }
done

rm -f "$system_view" "$network_view"

tmp="$system_menu.tmp"
jq 'del(."admin/system/plugins")' "$system_menu" > "$tmp"
mv "$tmp" "$system_menu"

tmp="$network_menu.tmp"
jq 'del(."admin/network/diagnostics")' "$network_menu" > "$tmp"
mv "$tmp" "$network_menu"

test ! -e "$system_view"
test ! -e "$network_view"
! grep -Fq '"admin/system/plugins"' "$system_menu"
! grep -Fq '"admin/network/diagnostics"' "$network_menu"
