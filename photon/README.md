# Photon OS Workflow

- Create VM
- Install Photon OS Minimal
- Login as Root

```bash
date -s "9 Oct 2020 11:11:11"
tdnf upgrade
useradd -m -G sudo vmstan
passwd vmstan
PASSWORD
```

- Login with SSH
- Exit Console

```bash
tdnf install open-vm-tools bindutils netmgmt wget python3-pip gcc build-essential python3-devel libffi-devel
```

- Power Off VM
- Edit Settings > Enable Time Sync
- Return to SSH

```bash
iptables -P INPUT ACCEPT
iptables-save > /etc/systemd/scripts/ip4save

systemctl start docker
systemctl enable docker
```

## Installing Docker Compose

```bash
pip3 install --upgrade pip
python3 -m pip install -IU docker-compose
```

## Static IP Configs

```bash
netmgr ip4_address --set --interface eth0 --mode static --addr 192.168.7.30/24 --gateway 192.168.7.1
netmgr dns_servers --set --mode static --servers 127.0.0.1,192.168.7.7
netmgr dns_domains --add --domains vmstan.net

netmgr dns_servers --set --mode static --servers 192.168.7.7,192.168.7.5
netmgr dns_domains --add --domains vmstan.net
```

## Photon OS 4 beta issue on ARM

Create `/etc/modprobe.d/blacklist.conf`  with `blacklist vsock_loopback`
