# DNS over TLS (DoT)

These instructions are based off the Pi-hole "[All Around DNS](https://docs.pi-hole.net/guides/unbound/)" instructions. However those instructions use Unbound as a full recursive resolver. Here we will use it to forward requests to a third-party resolver (Cloudflare, Quad9, Google, etc) in a secure manner using DNS over TLS (DoT).

DNS query example:

```
Client --(port 53, insecure)--> Pi-hole --(port 5353, locally)--> Unbound --(port 853, secure)--> Cloudflare/Quad9/Google
```

And then in reverse back to the client. Note that the DNS query outside your network is now encrypted. Local network traffic remains on standard DNS port/protocols.

## Installation

The first thing you need to do is to install the DNS resolver, Unbound, and download the DNS root hints. However, the root hints will not be used, we will define upstream DNS resolvers instead.

```
sudo apt install unbound
wget -O root.hints https://www.internic.net/domain/named.root
sudo mv root.hints /var/lib/unbound/
```

You will likely get an error that the Unbound service couldn't be started, this is because the configuration is missing.

## Configure Unbound

We will configure Unbound to:

- Listen only for queries from the local Pi-hole instance on port 5353.
- Verify DNSSEC signatures, discarding BOGUS domains.
- Forward all requests to upstream DNS resolvers only using DoT on port 853, as well as validate the certificate of the resolvers.
- Not resolve IPv6 addresses. (set `do-ip6` to `yes` bekow if you require this.)

Create a new file `/etc/unbound/unbound.conf.d/pi-hole.conf`

```
server:
    logfile: "/var/log/unbound/unbound.log"
    verbosity: 5

    interface: 127.0.0.1
    port: 5353
    do-ip4: yes
    do-udp: yes
    do-tcp: yes
    do-ip6: no
    prefer-ip6: no

    root-hints: "/var/lib/unbound/root.hints"

    harden-glue: yes
    harden-dnssec-stripped: yes
    use-caps-for-id: no

    edns-buffer-size: 1472
    prefetch: yes
    num-threads: 1
    so-rcvbuf: 1m

    qname-minimisation: yes
    prefetch: yes
    rrset-roundrobin: yes
    use-caps-for-id: yes

    private-address: 192.168.0.0/16
    private-address: 169.254.0.0/16
    private-address: 172.16.0.0/12
    private-address: 10.0.0.0/8
    private-address: fd00::/8
    private-address: fe80::/10

    tls-cert-bundle: /etc/ssl/certs/ca-certificates.crt

forward-zone:
    name: "."
    forward-addr: 1.1.1.1@853#cloudflare-dns.com
    forward-addr: 1.0.0.1@853#cloudflare-dns.com
    forward-addr: 9.9.9.9@853#dns.quad9.net
    forward-addr: 8.8.8.8@853#dns.google
    forward-ssl-upstream: yes
```

These four (Cloudflare twice) represent the four major providers of DNS over TLS. If you do not want to use one or more of these, simply comment them out with `#` or remove the line entirely.

Start Unbound and test that it's operational:

```
sudo service unbound start
dig vmstan.com @127.0.0.1 -p 5353
```

If it doesn't resolve the site, make sure you're not blocking outbound port 853 on a firewall.

## Test Validation

You can test TLS resolution using:

```
dig @127.0.0.1 -p 5353 is-dot.cloudflareresolve.com
```

You can test DNSSEC validation using:

```
dig sigfail.verteiltesysteme.net @127.0.0.1 -p 5353
dig sigok.verteiltesysteme.net @127.0.0.1 -p 5353
```

The first command should give a status report of SERVFAIL and no IP address. The second should give NOERROR plus an IP address.

## Pihole Configuration

Finally, configure Pi-hole to use your recursive DNS server by specifying 127.0.0.1#5335 as the Custom DNS (IPv4).

Don't forget to disable any of the built in DNS resolver options.