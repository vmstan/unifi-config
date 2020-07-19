# Pi-hole Configuration Changes

`/etc/pihole/pihole-FTL.conf`

- Enable IPv6 Resolution
- Ignore Localhost Lookups in Logs

`/etc/dnsmasq.d/10-dns-lookups.conf`

Adds non-default networks on USG to Pihole for reverse lookups.
