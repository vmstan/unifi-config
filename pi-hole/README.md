# Pi-hole Configuration Changes

`/etc/pihole/pihole-FTL.conf`

- Disable IPv6 Resolution
- Ignore Localhost Lookups in Logs

```
RESOLVE_IPV4=yes
RESOLVE_IPV6=no
IGNORE_LOCALHOST=yes
PRIVACYLEVEL=0
```

`/etc/dnsmasq.d/10-lan-lookups.conf`

Adds non-default networks on USG to Pihole for reverse lookups.

```
server=/8.168.192.in-addr.arpa/192.168.7.1
server=/9.168.192.in-addr.arpa/192.168.7.1

server=/guest.smg/192.168.7.1
server=/254.168.192.in-addr.arpa/192.168.7.1
```