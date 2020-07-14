# DNS over TLS (DoT)

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
"Client" ---> ( "Pi-Hole" ~~> "Stubby" ) ---> "Public Resolver" ---> "Global DNS"
"Client" <--- ( "Pi-Hole" <~~ "Stubby" ) <--- "Public Resolver" <--- "Global DNS"
```

Note that the DNS query outside your network is now encrypted. Local network traffic to the Pi-hole remains on standard unencrypted DNS port/protocols. Stubby is not configured to cache requests, simply to pass them to the next step. However your Pi-hole and the Public Resolver will cache lookups according to the TTL of the domain.

## Installation

The first thing you need to do is to install the DNS resolver, Stubby.

```
sudo apt install stubby
```

We will configure Stubby to:

- Listen only for queries from the local Pi-hole on interface 127.1.1.1.
- Forward all requests to upstream DNS resolvers only using DoT on port 853.
- Leverage multiple upstream resolvers in a round robin manner. (Cloudflare, Quad9, Google)
- Keep the TLS connection to the upstream resolver open, to speed up future requests.
- Set the threshold for failed upstream requests to remove a resolver from rotation.
- Not pass requests for local IP ranges (this should be handled by Pi-hole anyway.)

```
sudo rm /etc/stubby/stubby.yml
sudo wget -P /etc/stubby/ https://raw.githubusercontent.com/vmstan/unifi-config/master/stubby/stubby.yml
```

This file contains enteries for upstream resolvers that represent the three major providers of DNS over TLS. If you do not want to use one or more of these, simply comment them out with `#` or remove the line entirely.

Start Stubby and test that it's operational:

```
sudo service stubby restart
dig vmstan.com @127.0.0.1 -p 5353
```

If it doesn't resolve the site, make sure you're not blocking outbound port 853 to the IP addresses in the YAML file, on a firewall.

## Test Validation

You can test TLS resolution using:

```
dig is-dot.cloudflareresolve.com @127.0.0.1 -p 5353
```

You can test DNSSEC validation using:

```
dig sigfail.verteiltesysteme.net @127.0.0.1 -p 5353
dig sigok.verteiltesysteme.net @127.0.0.1 -p 5353
```

The first command should give a status report of SERVFAIL and no IP address. The second should give NOERROR plus an IP address.

## Pihole Configuration

Finally, configure Pi-hole to use your recursive DNS server by specifying `127.0.0.1#5353` as the Custom DNS (IPv4).

Don't forget to disable any of the built in DNS resolver options.

## Monitoring Traffic

Capturing firewall traffic through your USG. Use eth1 for the LAN traffic eth0 for WAN.

```
sudo tcpdump -npi eth# port 853
```