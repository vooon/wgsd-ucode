
const x = ubus.call("wireguard", "status");
if (!x)
	return false;

