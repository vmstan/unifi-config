# DNS over TLS (DoT)

## Background

From the "[All Around DNS](https://docs.pi-hole.net/guides/unbound/)" instructions on pi-hole.net:

> Pi-hole includes a caching and forwarding DNS server, now known as FTLDNS. After applying the blocking lists, it forwards requests made by the clients to configured upstream DNS server(s). 

There are four common methods for providing these upstream DNS instances that are popular with Pi-hole, and Pi-hole as it's commonly deployed from the installation script only takes advantage of one of those.

- Unencrypted traffic to an upstream resolver (default)
- Unencrypted traffic by running your own recursive resolver
- Encrypted traffic by tunneling DNS over HTTPS, referred to as "DoH"
- Encrypted traffic by sending DNS over TLS, referred to as "DoT"

Each option has various advantages and disadvantages and there is no single right method for all deployments. The default is easiest to setup out of the box as it does not require and additional software beyond Pi-hole, and should function on any network that can reach out to the Internet on port 53, which is open by most ISPs. At worst, you can use your ISPs resolvers if they block other providers. Using your ISPs DNS means they could (in theory) monitor your lookups and either sell this data. It's also unencrypted so anyone has visibility "on the wire" can also see what you're requesting.

Running your own recursive resolver is a great alternative, and offers more privacy than sending unencrypted requests to an upstream resolver, but it can be slower as your local system has to traverse the entire DNS flow to the DNS root servers, the authoritative resolvers for each TLD, the nameservers for a domain, subdomains, etc. Public resolvers typically already have this information in their cache, so those lookups are much quicker. Also, the requests are still unencrypted, so it's still possible to intercept the lookups.

DNS over HTTPS is popular, as it encrypts the DNS request inside of an HTTPS request (port 443) and sends them to a public resolver. There is protection not only from traffic monitoring on the wire, but also from seeing that any DNS lookups are being made as they're shoved inside of the rest of the HTTPS traffic that is going in and out of the network. The downside is you're reliant on a public provider for lookups.

DNS over TLS is an alternative, that also encrypts the DNS request with TLS, but instead uses port 853, and sends them to a public resolver. There are more protocol level differences happening, but the net effect is the same as DoH. The downsides are also the same as DoH, in that you're reliant on a public provider for lookups.

Here we will use it to forward requests to a third-party resolver (Cloudflare, Quad9, Google, etc) in a secure manner using DNS over TLS (DoT).

DNS query example:

```
"Client" -(port 53, insecure)-> "FTLDNS" -(127.1.1.1)--> "Stubby" -(port 853, secure)-> "Public Resolver"
```

And then in reverse back to the client. Note that the DNS query outside your network is now encrypted. Local network traffic remains on standard DNS port/protocols.

## Installation

The first thing you need to do is to install the DNS resolver, Unbound, and download the DNS root hints. However, the root hints will not be used, we will define upstream DNS resolvers instead.

```
sudo apt install stubby
```

We will configure Stubby to:

- Listen only for queries from the local Pi-hole on interface 127.1.1.1.
- Forward all requests to upstream DNS resolvers only using DoT on port 853.
- Not pass requests for local IP ranges (this should be handled by Pi-hole anyway.)

```
sudo rm /etc/stubby/stubby.yml
sudo wget -P /etc/stubby/ https://raw.githubusercontent.com/vmstan/unifi-config/master/stubby/stubby.xml
```

This file contains enteries for upstream resolvers that represent the three major providers of DNS over TLS. If you do not want to use one or more of these, simply comment them out with `#` or remove the line entirely.

Start Unbound and test that it's operational:

```
sudo service stubby restart
dig vmstan.com @127.1.1.1
```

If it doesn't resolve the site, make sure you're not blocking outbound port 853 on a firewall.

## Test Validation

You can test TLS resolution using:

```
dig @127.1.1.1 is-dot.cloudflareresolve.com
```

You can test DNSSEC validation using:

```
dig sigfail.verteiltesysteme.net @127.1.1.1
dig sigok.verteiltesysteme.net @127.1.1.1
```

The first command should give a status report of SERVFAIL and no IP address. The second should give NOERROR plus an IP address.

## Pihole Configuration

Finally, configure Pi-hole to use your recursive DNS server by specifying `127.1.1.1` as the Custom DNS (IPv4).

Don't forget to disable any of the built in DNS resolver options.

## Monitoring Traffic

Capturing firewall traffic through the USG. Use eth1 for the LAN traffic eth0 for WAN.

```
sudo tcpdump -npi eth# port 853
```