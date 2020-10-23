# Docker Settings

## Stubby

```bash
docker run -d \
--name=stubby \
-p 8053:8053/tcp \
-p 8053:8053/udp \
-v /home/vmstan/stubby/:/etc/stubby \
--restart=unless-stopped \
--network=dns \
kometchtech/stubby:latest
```

## Pihole

```bash
docker run -d \
--name pihole \
-e TZ=America/Chicago \
-e WEBPASSWORD=PASSWORD \
-p 53:53/tcp -p 53:53/udp \
-p 67:67/udp \
-p 80:80 \
-p 443:443 \
-v /home/vmstan/pihole/etc-pihole/:/etc/pihole \
-v /home/vmstan/pihole/etc-dnsmasq/:/etc/dnsmasq.d \
-e ServerIP="192.168.7.199" \
--restart=unless-stopped \
--cap-add=NET_ADMIN \
--dns=127.0.0.1 --dns=192.168.7.7 \
--network=dns \
--link stubby \
pihole/pihole:latest
```

## Homebridge

```bash
docker run -d \
  --restart unless-stopped \
  --net=host \
  --name=homebridge \
  -e TZ=America/Chicago \
  -e PUID=0 -e PGID=0 \
  -e HOMEBRIDGE_CONFIG_UI=1 \
  -e HOMEBRIDGE_CONFIG_UI_PORT=8080 \
  -v /home/vmstan/homebridge:/homebridge \
oznu/homebridge
```

## Channels DVR

```bash
docker run -d \
  --name=channels-dvr \
  --net=host \
  --restart=unless-stopped \
  --device /dev/dri:/dev/dri \
  --volume /home/vmstan/channels-dvr/config:/channels-dvr \
  --volume /home/vmstan/channels-dvr/media:/shares/DVR \
fancybits/channels-dvr:tve
```

## Wireguard

```bash
docker run -d \
 --name=wireguard \
 --cap-add=NET_ADMIN \
 --cap-add=SYS_MODULE \
 -e PUID=0 \
 -e PGID=0 \
 -e TZ=America/Chicago \
 -e SERVERURL=vmstan.net \
 -e SERVERPORT=51820 \
 -e PEERS=2 \
 -e PEERDNS=192.168.7.7,192.168.7.5 \
 -e INTERNAL_SUBNET=192.168.11.0 \
 -e ALLOWEDIPS=192.168.7.7/32,192.168.7.5/32 \
 -p 51820:51820/udp \
 -v /home/vmstan/wireguard:/config \
 -v /lib/modules:/lib/modules \
 --sysctl="net.ipv4.conf.all.src_valid_mark=1" \
 --restart unless-stopped \
linuxserver/wireguard
```

## Cloudflared

```bash
docker run -d \
 --name=cloudflared \
 -p 5053:5053/udp \
 -p 49312:49312 \
 -e TZ=America/Chicago \
crazymax/cloudflared:latest
```

## Unbound

```bash
docker run -d \
 --name unbound-rpi \
 -e PUID=0 \
 -e PGID=0 \
 --net=host \
 -p 5335:5335/udp \
 -p 5335:5335/tcp \
 -v /home/pi/unbound:/opt/unbound/etc/unbound/ \
 --restart=always \
mvance/unbound-rpi:latest
```
