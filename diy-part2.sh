#!/bin/bash
#
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#

# Modify default IP
#sed -i 's/192.168.1.1/192.168.50.5/g' package/base-files/files/bin/config_generate

wget -P ./target/linux/ipq40xx/patches-5.15/ https://raw.githubusercontent.com/usakicha/lede/master/target/linux/ipq40xx/patches-5.4/999-ipq40xx-unlock-cpu-frequency.patch
echo "src-git-full luci2 https://github.com/coolsnowwolf/luci.git" >> ./feeds.conf.default
./scripts/feeds update luci2
./scripts/feeds install luci-app-cpufreq
./scripts/feeds install luci-app-diskman
sed -i 's/set wireless.${name}.disabled=1/set wireless.${name}.disabled=0/g' ./package/kernel/mac80211/files/lib/wifi/mac80211.sh
wget -P ./package/base-files/files/usr/local/share/xray/ https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geoip.dat
wget -P ./package/base-files/files/usr/local/share/xray/ https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat
#~/work/Actions-OpenWrt/Actions-OpenWrt/
