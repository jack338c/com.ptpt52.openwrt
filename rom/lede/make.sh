#!/bin/sh

test -n "$CFGS" || CFGS="`cat feeds/ptpt52/rom/lede/cfg.list`"

test -n "$IDXS" || IDXS="0"

test -n "$CONFIG_VERSION_NUMBER" || CONFIG_VERSION_NUMBER="3.0.0_build`date +%Y%m%d%H%M`"

echo build starting
echo "CFGS=[$CFGS]"
echo "IDXS=[$IDXS]"
echo "CONFIG_VERSION_NUMBER=$CONFIG_VERSION_NUMBER"
sleep 5

find feeds/luci/ -type f | grep -v .git\* | while read file; do
	sed -i 's/192\.168\.1\./192\.168\.15\./g' "$file" && echo modifying $file
done

CONFIG_VERSION_DIST="PTPT52"
CONFIG_VERSION_NICK="fuckgfw"
CONFIG_VERSION_MANUFACTURER_URL="http://router.ptpt52.com/"
for i in $IDXS; do
	[ $i = 1 ] && {
		CONFIG_VERSION_DIST="BICT"
		CONFIG_VERSION_NICK="router"
		CONFIG_VERSION_MANUFACTURER_URL="http://bict.cn/"
	}

	touch ./package/base-files/Makefile

	for cfg in $CFGS; do
	set -x
		cp feeds/ptpt52/rom/lede/$cfg .config
		sed -i "s/CONFIG_VERSION_NUMBER=\".*\"/CONFIG_VERSION_NUMBER=\"$CONFIG_VERSION_NUMBER\"/" ./.config
		sed -i "s/CONFIG_VERSION_DIST=\".*\"/CONFIG_VERSION_DIST=\"$CONFIG_VERSION_DIST\"/" ./.config
		sed -i "s/CONFIG_VERSION_NICK=\".*\"/CONFIG_VERSION_NICK=\"$CONFIG_VERSION_NICK\"/" ./.config
		sed -i "s%CONFIG_VERSION_MANUFACTURER_URL=\".*\"%CONFIG_VERSION_MANUFACTURER_URL=\"$CONFIG_VERSION_MANUFACTURER_URL\"%" ./.config
		touch ./package/base-files/files/etc/openwrt_release
		set +x
		test -n "$1" || exit 255
		$* || exit 255
	done
done

build_in=$(cd feeds/ptpt52/rom/lede/ && cat $CFGS | grep TARGET_DEVICE_.*=y | sed 's/CONFIG_//;s/=y//' | wc -l)
build_out=$(find bin/targets/ | grep -- '\(-squashfs\|-factory\|-sysupgrade\)' | grep -v factory | grep ptpt52 | grep -v root | grep -v kernel | sort | wc -l)
echo in=$build_in out=$build_out
echo
