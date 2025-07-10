// wgsd-client
//vim:set ts=4 sw=4 noet ft=javascript:

import * as log from "log";
import { connect } from "ubus";
import { b32enc } from "base32";
import * as resolv from "resolv";
import * as socket from "socket";

function get_addr(r) {
	if (exists(r, 'rcode') && r.rcode === "NXDOMAIN") {
		log.ERR("Domain not found: %s\n", qhost);
		return null;
	}

	// Unsure what address i should prefer, but for now A seems more reliable than AAAA.
	if (exists(r, "A")) {
		return r["A"][0];
	} else if (exists(r, "AAAA")) {
		return r["AAAA"][0];
	}

	return null;
}

function resolve_dns_server() {
	const ns_sep_idx = rindex(dns_server, ":");
	let ns_domain = dns_server;
	let ns_port = "53";
	if (ns_sep_idx > 0) {
		ns_domain = substr(dns_server, 0, ns_sep_idx);
		ns_port = substr(dns_server, ns_sep_idx + 1);
	}

	const addrs = socket.addrinfo(ns_domain);
	assert(length(addrs) > 0, "dns resolve error");

	// TODO: better address peak up
	const addr = addrs[0].addr.address;
	assert(addr, "bad address");

	return `${ addr }#${ ns_port }`;
}


// log.openlog(`wgsd-client.${ device }`, log.LOG_CONS, log.LOG_DAEMON);
log.ulog_open(["syslog", "stdio"], "daemon", `wgsd-client.${ device }`);

const bus = connect();
assert(bus, "failed to connect to ubus");

const wgst = bus.call(rpc_object, "status");
assert(wgst, "rpc error");

const info = wgst[device];
assert(info, "device not found");

const peers = info["peers"];

dns_server = resolve_dns_server();
log.NOTE("Resolved DNS server: %s\n", dns_server);

// drop ending dot
zone = rtrim(zone, ".");

let queries = {};

for (peer, data in peers) {
	const p32 = b32enc(b64dec(peer));
	const host = lc(`${ p32 }._wireguard._udp.${ zone }`);

	q = {
		peer: peer,
		host: host,
		srv_port: 0,
		srv_host: '',
		addr: '',
		not_found: false,
		endpoint: data.endpoint,
		allowed_ips: data.allowed_ips || [],
	};

	queries[host] = q;

	log.NOTE("Prepare query for peer: %s\n", peer);
}

// 1. Query SRV

// NOTE: map() does not work on dicts
let srv_hosts = [];
for (peer, q in queries) {
	push(srv_hosts, q.host);
}

log.INFO("Quering SRV for %d hosts...\n", length(srv_hosts));

const srv_opts = {
	type: "SRV",
	// BUG: https://github.com/jow-/ucode/issues/313
	nameserver: `${dns_server}`,
};

srvs = resolv.query(srv_hosts, srv_opts);
if (!srvs) {
	err = resolv.error();
	log.ERR("Failed to resolve: %s\n", err);
	exit(1);
}

for (host, resp in srvs) {
	let q = queries[host];
	assert(q, "unexpected host");

	if (exists(resp, 'rcode')) {
		log.WARN("Peer SRV: %s, host: %s, rcode: %s\n", q.peer, host, resp.rcode);
		q.not_found = true;
		continue;
	}

	let srv = resp.SRV[0];

	q.srv_port = srv[2];
	q.srv_host = srv[3];

	// in general, SRV may respond with different host, but it's not expected at all.
	assert(host == q.srv_host, "unexpected srv host");
}

// 2. Query A/AAAA

let addr_hosts = [];
for (peer, q in queries) {
	if (q.not_found) {
		continue;
	}

	push(addr_hosts, q.srv_host);
}

log.INFO("Quering A/AAAA %d records...\n", length(addr_hosts));

const addr_opts = {
	// BUG: https://github.com/jow-/ucode/issues/313
	nameserver: `${dns_server}`,
};

addrs = resolv.query(addr_hosts, addr_opts);
if (!addrs) {
	err = resolv.error();
	log.ERR("Failed to resolve: %s\n", err);
	exit(1);
}

for (host, resp in addrs) {
	let q = queries[host];
	assert(q, "unexpected host");

	if (resp.rcode === "NXDOMAIN") {
		log.WARN("Peer A/AAAA not found: %s, host: %s\n", q.peer, host);
		q.not_found = true;
		continue;
	}

	q.addr = get_addr(resp);
}

// 3. Parse TXT?
// TODO skip. Original also don't do that...

log.INFO("Resolve complete. Applying...\n");

for (host, q in queries) {
	if (q.not_found) {
		log.INFO("Peer info not found, skipping: %s\n", q.peer);
		continue;
	}

	let endpoint = `${ q.addr }:${ q.srv_port }`;
	if (q.endpoint === endpoint) {
		log.INFO("Peer endpoint match, nothing to do: %s - %s\n", q.peer, q.endpoint);
		continue;
	}

	log.NOTE("Changing peer endpoint: %s, %s -> %s\n", q.peer, q.endpoint, endpoint);

	const args = [wg_bin, 'set', device, 'peer', q.peer, 'endpoint', endpoint];
	log.ulog(log.LOG_DEBUG, "Execute command: %s\n", args);

	rc = system(args);
	if (rc != 0) {
		log.ERR("Failed to apply change for peer: %s, rc: %d\n", q.peer, rc);
	}
}

log.NOTE("Done.\n");
