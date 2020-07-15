# DNS over TLS (DoT) w/ Stubby

## Background

From the "[All Around DNS](https://docs.pi-hole.net/guides/unbound/)" instructions on pi-hole.net:

> Pi-hole includes a caching and forwarding DNS server, now known as FTLDNS. After applying the blocking lists, it forwards requests made by the clients to configured upstream DNS server(s). 

There are four common methods for providing these upstream DNS instances that are popular with Pi-hole users. Pi-hole as it's commonly deployed from the installation script only takes advantage of one of these methods.

- Unencrypted traffic to an shared upstream resolver 
- Unencrypted traffic by running your own private recursive resolver
- Encrypted traffic by tunneling DNS over HTTPS, referred to as "DoH" 
- Encrypted traffic by sending DNS over TLS, referred to as "DoT"

Each option has various advantages and disadvantages and there is no single right method for all deployments. 

Here we will setup to encrypt upstream DNS requests and send them over port 853 to a public resolver (Cloudflare, Quad9, Google, etc) in a secure manner using DNS over TLS (DoT).

DNS query example:

```
"Client" ---> ( "Pi-Hole" ~~> "Stubby" ) ===> "Public Resolver" ---+ "Global DNS"
"Client" <--- ( "Pi-Hole" <~~ "Stubby" ) <=== "Public Resolver" +--- "Global DNS"
```

Note that the DNS query outside your network is now encrypted. Local network traffic to the Pi-hole remains on standard unencrypted DNS port/protocols. Stubby is not configured to cache requests, simply to pass them to the next step. However your Pi-hole and the Public Resolver will cache lookups according to the TTL of the domain.

## Installation

The first thing you need to do is to install the DNS resolver, Stubby.

```
sudo apt install stubby
```

(On Raspbian/Ubuntu/Debian-based distros use the above command. It should be available in other package managers. You can also install it from scratch by [following these instructions](https://dnsprivacy.org/wiki/display/DP/DNS+Privacy+Daemon+-+Stubby#DNSPrivacyDaemonStubby-InstallationGuides).)

We will configure Stubby to:

- Listen only for queries from the local Pi-hole server on loopback interface 127.1.1.53.
- Forward all requests to upstream DNS resolvers only using DoT on port 853.
- Leverage a unfiltered Cloudflare as the primary upstream resolver.
- Failover quickly to the alternate IP for that resolver, should it be necessary.
- Keep the TLS connection to the upstream resolver open, to speed up future requests.
- Not pass requests for local IP ranges (this should be handled by Pi-hole anyway.)

### IPv4 Only Networks
```
cd /etc/stubby
sudo rm stubby.yml
sudo wget -cO - https://raw.githubusercontent.com/vmstan/unifi-config/master/stubby/stubby-4.yml > stubby.yml
```

### IPv6 Enabled Networks
```
cd /etc/stubby
sudo rm stubby.yml
sudo wget -cO - https://raw.githubusercontent.com/vmstan/unifi-config/master/stubby/stubby-6.yml > stubby.yml
```

This file contains enteries for upstream resolvers that represent the three major providers of DNS over TLS. If you do not want to use one or more of these, simply comment them out with `#` or remove the line entirely. Verify the resolvers you want to use are not commented out.

Start Stubby and test that it's operational:

```
sudo service stubby restart
dig vmstan.com @127.1.1.53
```

If it doesn't resolve the site, make sure you're not blocking outbound port 853 to the IP addresses in the YAML file, on a firewall.

## Test Validation

**You can test TLS resolution using:**

```
dig is-dot.cloudflareresolve.com @127.1.1.53
```

This will only resolve an IP address if the incoming request is via TLS port 853.

**You can test DNSSEC validation using:**

```
dig sigfail.verteiltesysteme.net @127.1.1.53
dig sigok.verteiltesysteme.net @127.1.1.53
```

The first command should give a status report of `SERVFAIL` and no IP address. The second should give `NOERROR` plus an IP address.

**You can test IPv6 (AAAA) lookups using:**

```
dig aaaa google.com @127.1.1.53
```

## Pihole Configuration

Finally, configure Pi-hole to use Stubby under `Settings > DNS > Upstream DNS Servers` in the user interface and specifying `127.1.1.53` as the Custom DNS (IPv4) and/or `0::1#5353` as the Custom DNS (IPv6) resolver. Leave `Use DNSSEC` unchecked, as Cloudflare does this for us.

_Don't forget to disable any of the built in DNS resolver options._

Under `Local DNS Records` in the Pi-hole interface, add the domain `stubby` and the IP address `127.1.1.53` -- this will allow your stats to show Stubby as the destination for non-blocked/non-cached requests instead of the IP address.

## Monitoring Traffic

Capturing firewall traffic through your USG. Use eth1 for the LAN traffic eth0 for WAN.

```
sudo tcpdump -npi eth# port 853
```