#!/bin/sh

. /lib/functions/network.sh

panic() {
	echo "$@" 1>&2
	exit 1
}

interface=""
zone=""
ttl="60"
nosleep="0"

while getopts "i:z:t:F" opt; do
	case $opt in
		i)
			interface="${OPTARG}"
			;;
		z)
			zone="${OPTARG}"
			;;
		t)
			ttl="${OPTARG}"
			;;
		F)
			nosleep="1"
			;;
	esac
done

if [ -z "$interface" ] || [ -z "$zone" ]; then
	panic "-i and -z required"
fi

network_get_device device "$interface" || panic "failed to get interface: $interface"
network_get_protocol protocol "$interface"

case $protocol in
	wireguard|amneziawg)
		rpc_object="$protocol"
		;;
	*)
		panic "unknown protocol: $protocol"
		;;
esac

zone_file="/tmp/wgsd/${zone}zone"
mkdir -p "$(dirname "$zone_file")"

while true; do
	ucode -Ddevice="$device" -Drpc_object="$rpc_object" -Dzone="$zone" -Dttl="$ttl" \
		-T /usr/share/ucode/wgsd/zone.uc > "$zone_file"
	[ $nosleep -gt 0 ] && exit
	sleep "$ttl"
done
