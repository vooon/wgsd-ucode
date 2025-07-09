wgsd-ucode
==========

Implementation of [wgsd][1] on OpenWRT's ucode.

This version has tho parts:

- `wgsd-gen-zone` - a registry side part, which generates zone file for DNS server
- `wgsd-client` - client, which resolves endpoints and updates WG/AWG endpoints


Installation
------------

It is OpenWRT feed with extra packages.

Add this line to `feeds.conf`:
```
src-git wgsduc https://github.com/vooon/wgsd-ucode.git
```


[1]: https://github.com/jwhited/wgsd
