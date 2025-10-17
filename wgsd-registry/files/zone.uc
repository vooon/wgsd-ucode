{#
 # Zone file template
 #}
{%

import { connect } from "ubus";
import { b32enc } from "base32";

const bus = connect();

function enc_peer(d) {
	return lc(b32enc(d));
}

function enc_peer_no_padding(d) {
	return rtrim(enc_peer(d), "=");
}

%}
$ORIGIN {{ zone }}
$TTL {{ ttl }}

@ IN SOA ns hostmaster (
		{{ time() }}   ; serial
		1H           ; refresh
		600          ; retry
		1W           ; expire
		1D           ; minimum
		)

{%

const x = bus.call(rpc_object, "status");
assert(x, "rpc error");
assert(exists(x, device), "no device status");

const peers = x[device]["peers"];

%}
{% for (peer, data in peers): %}
{%   if (!data.last_handshake): %}
;; Peer: {{ peer }} is offline, skipping
{%   else %}
{%
       const peer_bin = b64dec(peer);
       const peer_hash = enc_peer(peer_bin);
       const peer_hash_np = enc_peer_no_padding(peer_bin);
       const peer_host = `${ peer_hash }._wireguard._udp`;
       const peer_host_np = `${ peer_hash_np }._wireguard._udp`;
       const endpoint = data.endpoint;
       // const ep_addr = socket.sockaddr(endpoint);  // XXX BUG return null!
       // const ep_type = (ep_addr.family == socket.AF_INET6) ? "AAAA" : "A";
       // assert(ep_addr, "endpoint parse error");
       const port_sep = rindex(endpoint, ':');
       const ep_addr = rtrim(ltrim(substr(endpoint, 0, port_sep), "["), "]");
       const ep_port = substr(endpoint, port_sep + 1);
       const ep_type = (index(ep_addr, ':') >= 0) ? "AAAA" : "A";
       assert(endpoint, "no endpoint");
       const allowed = join(",", data.allowed_ips);
%}
;; Peer: {{ peer }} - {{ endpoint }}
_wireguard._udp IN PTR {{ peer_host }}
{{ peer_host }} IN {{ ep_type }} {{ ep_addr }}
{{ peer_host }} IN SRV 0 0 {{ ep_port }} {{ peer_host }}
{{ peer_host }} IN TXT "txtvers=1" "pub={{ peer }}" "allowed={{ allowed }}"{# original wgsd format #}
{{ peer_host }} IN TXT "v=WGSD1;pub={{ peer }};allowed={{ allowed }}"{# alternative format to fix bug https://github.com/jow-/ucode/issues/315 #}
{%     if (peer_host != peer_host_np): %}
_wireguard._udp IN PTR {{ peer_host_np }}
{{ peer_host_np }} IN {{ ep_type }} {{ ep_addr }}
{{ peer_host_np }} IN SRV 0 0 {{ ep_port }} {{ peer_host_np }}
{{ peer_host_np }} IN TXT "txtvers=1" "pub={{ peer }}" "allowed={{ allowed }}"
{{ peer_host_np }} IN TXT "v=WGSD1;pub={{ peer }};allowed={{ allowed }}"
{%     endif %}
{%   endif %}
{% endfor %}
