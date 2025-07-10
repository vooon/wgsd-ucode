// wgsd-client
//vim:set ts=4 sw=4 noet ft=javascript:

import * as log from "log";
import { connect } from "ubus";
import { b32enc } from "base32";
import * as resolv from "resolv";

function get_addr(qhost, qret) {
	const r = qret[qhost];
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

	ret = resolv.query([ns_domain]);
	if (!ret || !ret[ns_domain] || ret[ns_domain]["rcode"] === "NXDOMAIN") {
		log.ERR("Failed to resolve dns server address, host: %s, return: %s, error: %s\n", ns_domain, ret, resolv.error());
		exit(1);
	}

	addr = get_addr(ns_domain, ret);
	assert(addr, "impossibru!");

	return `${ addr }#${ ns_port }`;
}


log.openlog(`wgsd-client.${ device }`, log.LOG_CONS, log.LOG_DAEMON);

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
		endpoint: '',
		allowed_ips: [],
		not_found: false,
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

log.INFO("Quering SRV %d records...\n", length(srv_hosts));

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

	if (resp.rcode === "NXDOMAIN") {
		log.WARN("Peer SRV not found: %s, host: %s\n", q.peer, host);
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

	q.addr = get_addr(host, resp);
}



log.INFO(`res: ${ q }\n`);
