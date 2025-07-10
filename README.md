wgsd-ucode
==========

Implementation of [wgsd][1] on OpenWRT's [ucode][2].

Goal of that implementation is to support AmneziaWG, a variation of WireGuard.
It have a little bit different netlink protocol, so usual golang wireguard control module would not work.
So instead of forking all required parts, i decided just to script that out on the existing language.
That also makes whole thing much smaller, as you don't have to carry Go runtime.

This version has tho parts:

- `wgsd-registry` - a registry side part, which generates zone file for DNS server
- `wgsd-client` - client, which resolves endpoints and updates WG/AWG endpoints


Installation
------------

It is OpenWRT feed with extra packages.

Add this line to `feeds.conf`:
```
src-git wgsduc https://github.com/vooon/wgsd-ucode.git
```


wgsd-registry
-------------

This service periodically regenerates RFC1035 DNS zone files.

Configuration done trough the UCI interface. Service can run multiple instances for each interface.

Instances defined by config section of type `registry`. See the example file.

| Option | Req | Description |
|--------|-----|-------------|
| disabled | No | Disable registry instance. Default 0. |
| interface | Yes | Network interface, must be of wireguard or amneziawg protocol |
| zone | Yes | Base domain zone. Must end with dot. |
| ttl | No | Time to leave for records and file regeneration. Default 60 seconds. |



[1]: https://github.com/jwhited/wgsd
[2]: https://ucode.mein.io/
