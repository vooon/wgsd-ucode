#!/bin/sh

. /lib/functions/network.sh

panic() {
	echo "$@" 1>&2
	exit 1
}

interface=""
dns_server=""
zone=""

while getopts "i:z:s:" opt; do
	case $opt in
		i)
			interface="${OPTARG}"
			;;
		z)
			zone="${OPTARG}"
			;;
		s)
			dns_server="${OPTARG}"
			;;
	esac
done

if [ -z "$interface" ] || [ -z "$zone" ] || [ -z "$dns_server" ]; then
	panic "-i, -s and -z required"
fi

network_get_device device "$interface" || panic "failed to get interface: $interface"
network_get_protocol protocol "$interface"

case $protocol in
	wireguard)
		rpc_object="$protocol"
		wg_bin="/usr/bin/wg"
		;;
	amneziawg)
		rpc_object="$protocol"
		wg_bin="/usr/bin/awg"
		;;
	*)
		panic "unknown protocol: $protocol"
		;;
esac

ucode \
	-Ddevice="$device" -Drpc_object="$rpc_object" -Dwg_bin="$wg_bin" \
	-Dzone="$zone" -Ddns_server="$dns_server" \
	/usr/share/ucode/wgsd/client.uc
exit $?
