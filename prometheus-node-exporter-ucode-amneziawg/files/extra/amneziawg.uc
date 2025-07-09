import { cursor } from "uci";

const x = ubus.call("amneziawg", "status");
if (!x)
	return false;

const uci = cursor();
uci.load("network");

let m_wg_iface_info = gauge("amneziawg_interface_info");
let m_wg_peer_info = gauge("amneziawg_peer_info");
let m_wg_handshake = gauge ("amneziawg_latest_handshake_seconds");
let m_wg_rx = gauge ("amneziawg_received_bytes_total");
let m_wg_tx = gauge ("amneziawg_sent_bytes_total");

for (let iface in x) {
	const wc = x[iface];

	m_wg_iface_info({
		name: iface,
		public_key: wc["public_key"],
		listen_port: wc["listen_port"],
		fwmark: wc["fwmark"] || NaN,
	}, 1);

	for (let peer in wc["peers"]) {
		let description;
		uci.foreach('network', `amneziawg_${iface}`, (s) => {
			if (s.public_key == peer)
				description = s.description;
		});

		const pc = wc["peers"][peer];

		m_wg_peer_info({
			interface: iface,
			public_key: peer,
			description,
			endpoint: pc["endpoint"],
			persistent_keepalive_interval: pc["persistent_keepalive_interval"] || NaN,
		}, 1);

		const labels = { public_key: peer };

		m_wg_handshake(labels, pc["last_handshake"]);
		m_wg_rx(labels, pc["rx_bytes"]);
		m_wg_tx(labels, pc["tx_bytes"]);
	}
}
